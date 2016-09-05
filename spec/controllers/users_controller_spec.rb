require 'rails_helper'

describe UsersController, 'GET#index' do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in user

    get :index
  end

  it 'assigns all users to @users' do
    expect(assigns(:users)).to eq(User.all)
  end

  it 'renders index template' do
    expect(response).to render_template(:index)
  end
end
