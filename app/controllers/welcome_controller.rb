require 'pdf/reader'

class WelcomeController < ApplicationController

  def index; end
  def srt_doc_landing; end
  def pdf_txt_cont_landing; end
  def pdf_txt_hbo_landing; end
  def xlsx_txt_amedia_landing; end


  def srt_to_doc
    tmp = params[:srt].tempfile

    ary = []

    File.new(tmp).each_with_index do |line, index|
      next if index == 0
      qw = line.strip
      matching =
          if qw.match(/-->/).present?
            # qw.split('-->').first.strip[0...-1]
            arr = qw.split('-->').first.split(':')
            "#{arr[1]}:#{arr[2].split(',').first}"

          elsif !/\A\d+\z/.match(qw)
            qw
          end

      ary << matching if matching.present?
    end

    target = ary.in_groups_of(3)

    doc = Doc.create(doc_data: { srt_data: target.unshift(["Timecode", "Character", "Dialogue"]) } )

    cookies[:doc_id] = doc.id

    redirect_to karakal_doc_welcome_index_path
  end

  def karakal_doc
    rec = Doc.find(cookies[:doc_id])
    @srt_data = rec.doc_data['srt_data']

    respond_to do |format|
      format.docx { headers["Content-Disposition"] = "attachment; filename=\"caracal1.docx\"" }
    end
  end

  def pdf_txt_cont_parse
    tmp = params[:pdf].tempfile
    reader = PDF::Reader.new(tmp)
    is_script_begin = false
    path = "public/#{params[:pdf].original_filename.split('.').first}.txt"
    f = File.new(path, 'w')
    reader.pages.each do |page|
      page.text.each_line do |line|
        str = line.chomp.squeeze(" ")
        timecode = str[/(?:[01]\d|2[0-3]):(?:[0-5]\d):(?:[0-5]\d):(?:[0-5]\d)/]
        character = str[/(?<!\[)\b[A-Z][A-Z]+\b(?![\w\s]*[\]])/]
        dialogue = str.gsub(/(?:[01]\d|2[0-3]):(?:[0-5]\d):(?:[0-5]\d):(?:[0-5]\d)|(?<!\[)\b[A-Z][A-Z]+\b(?![\w\s]*[\]])/, '')

        if dialogue == ' Timecode Character Dialogue Translation'
          is_script_begin = true
          next
        end

        next unless is_script_begin

        if timecode.present?
          ary = timecode.split(':')
          normalized_timecode = "#{ary[1]}:#{ary[2]}"

          f.write("#{normalized_timecode.chomp.strip}\n")
        end

        f.write("#{character.chomp.strip}\n") if character.present? && character.length > 1
        f.write("#{dialogue.chomp.strip}\n") if dialogue.present?
      end
    end

    f.close

    file = f.path
    File.open(file, 'r') do |f|
      send_data f.read.force_encoding('BINARY'), :filename => "#{params[:pdf].original_filename.split('.').first}.txt", :disposition => "attachment"
    end
    File.delete(file)
  end

  def xlsx_txt_amedia_parse
    tmp = params[:xls].tempfile
    xlsx = Roo::Spreadsheet.open(tmp)
    path = "public/#{params[:xls].original_filename.split('.').first}.txt"
    f = File.new(path, 'w')

    xlsx.each_with_pagename do |name, sheet|
      sheet.each do |ary|
        next if ary.first == sheet.row(1).first
        next if ary.first.blank?
        next if ary[3].blank?

        timecode = ary.first
        character = ary[2]
        dialogue = ary[3]

        if timecode.present?
          ary = timecode.split(':')
          normalized_timecode = "#{ary[1]}:#{ary[2]}"

          f.write("#{normalized_timecode.chomp.strip}\n")
        end

        if character.present?
          normalized_character = character.split.first

          f.write("#{normalized_character.chomp.strip}\n")
        end

        if dialogue.present?
          dialogue = dialogue.gsub(/\r|\n|\t/,'')
          dialogue = dialogue.gsub(/\b[A-Z][A-Z]+\b/, &:downcase)

          f.write("#{dialogue.chomp.strip}\n")
        end
      end
    end

    f.close

    file = f.path
    File.open(file, 'r') do |f|
      send_data f.read.force_encoding('BINARY'), :filename => "#{params[:xls].original_filename.split('.').first}.txt", :disposition => "attachment"
    end
    File.delete(file)
  end
end