class ColorifysController < ApplicationController

  def new
  end

  def show
    @doc = Doc.find(params[:id])
  end

  def create
    doc = Docx::Document.open(params[:docx])
    doc_data = []
    character = false
    characters = []

    doc.tables[0].columns.each do |column| # Column-based iteration
      column.cells.each do |cell|
        character = true if cell.text == 'Персонаж'
        character = false if cell.text == 'Timecode' || cell.text == 'Текст'

        if character
          characters << cell.text if characters.exclude?(cell.text)
        end
      end
    end

    doc.tables.each do |table|
      table.rows.each do |row| # Row-based iteration
        row_data = []
        row.cells.each do |cell|
          row_data << cell.text
        end
        doc_data << row_data
      end
    end

    doc = Doc.create(doc_data: { doc_data: doc_data }, characters_data: {characters: characters} )

    redirect_to colorify_path(doc)
  end
end
