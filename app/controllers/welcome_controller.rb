require 'fileutils'

class WelcomeController < ApplicationController

  def index
    @qwerty = 'SRT to Doc'
  end

  def srt_to_doc
    tmp = params[:srt].tempfile

    ary = []

    File.new(tmp).each_with_index do |line, index|
      next if index == 0
      qw = line.strip
      matching =
          if qw.match(/-->/).present?
            qw.split('-->').first.strip[0...-1]

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
end