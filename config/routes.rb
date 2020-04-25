Rails.application.routes.draw do

  root to: 'welcome#index'

  resources :welcome do
    collection do
      post :srt_to_doc
      get :karakal_doc, format: 'docx'
    end
  end
end
