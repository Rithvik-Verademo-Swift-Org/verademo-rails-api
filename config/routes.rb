Rails.application.routes.draw do
  # Root health check
  root to: proc { [200, {}, ['VerademoAPI is operational!']] }

  # Users endpoints
  scope '/users' do
    post 'register', to: 'users#register'
    post 'login', to: 'users#login'
    get 'getUsers', to: 'users#get_users'
    get 'getUser', to: 'users#get_user'
    get 'getBlabbers', to: 'users#get_blabbers'
    get 'getProfileInfo', to: 'users#get_profile_info'
    get 'getEvents', to: 'users#get_events'
    get 'reset', to: 'users#reset'
    post 'updateProfile', to: 'users#update_profile'
    post 'listen', to: 'users#listen'
    post 'ignore', to: 'users#ignore'
  end

  # Posts/Blabs endpoints
  scope '/posts' do
    get 'getBlabsForMe', to: 'posts#get_blabs_for_me'
    get 'getBlabsByMe', to: 'posts#get_blabs_by_me'
    get 'getAllBlabs', to: 'posts#get_all_blabs'
    post 'addBlab', to: 'posts#add_blab'
    post 'getBlabComments', to: 'posts#get_blab_comments'
    post 'addBlabComment', to: 'posts#add_blab_comment'
    delete 'deleteBlab', to: 'posts#delete_blab'
  end

  # Admin endpoints
  scope '/admin' do
    post 'runCommand', to: 'admin#run_command'
    post 'getFile', to: 'admin#get_file'
  end
end
