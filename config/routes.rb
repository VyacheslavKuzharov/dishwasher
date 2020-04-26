Rails.application.routes.draw do

  root to: 'welcome#index'

  resources :welcome do
    collection do
      get :srt_doc_landing
      get :pdf_txt_cont_landing
      post :srt_to_doc
      post :pdf_txt_cont_parse
      get :karakal_doc, format: 'docx'
    end
  end
end
