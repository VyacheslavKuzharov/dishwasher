Rails.application.routes.draw do

  root to: 'welcome#index'

  resources :welcome do
    collection do
      get :srt_doc_landing
      get :pdf_txt_3_landing
      get :xlsx_txt_amedia_landing
      post :srt_to_doc
      post :pdf_txt_cont_parse
      post :xlsx_txt_amedia_parse
      get :karakal_doc, format: 'docx'
    end
  end
end
