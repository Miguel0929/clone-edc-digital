require 'rails_helper'

describe ProgramsController, 'GET#index' do
  let(:user) { FactoryGirl.create(:user)}

  before do
    sign_in user
    get :index
  end

  it 'assigns all programs to @programs' do
    expect(assigns(:programs)).to eq(Program.all)
  end

  it 'renders index template' do
    expect(response).to render_template(:index)
  end
end

describe ProgramsController, 'GET#show' do
  let(:user) { FactoryGirl.create(:user) }
  let(:program) { FactoryGirl.create(:program) }

  before do
    sign_in user
    get :show, id: program.id
  end

  it 'finds the program' do
    expect(assigns(:program)).to eq(program)
  end

  it 'renders show template' do
    expect(response).to render_template(:show)
  end
end

describe ProgramsController, 'GET#new' do
  let(:user) { FactoryGirl.create(:user)}

  before do
    sign_in user
    get :new
  end

  it 'creates a new Program instance' do
    expect(assigns(:program)).to be_a_new(Program)
  end

  it 'renders new template' do
    expect(response).to render_template(:new)
  end
end

describe ProgramsController, 'POST#create' do
  let(:user) { FactoryGirl.create(:user)}

  before { sign_in user }

  context 'when has valid params' do
    before { post :create, program: FactoryGirl.attributes_for(:program) }

    it 'redirect to program' do
      expect(response).to redirect_to(Program.last)
    end
  end

  context 'when has not valid params' do
    before { post :create, program: FactoryGirl.attributes_for(:program, name: nil) }

    it 'renders new template' do
      expect(response).to render_template(:new)
    end
  end
end

describe ProgramsController, 'GET#edit' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }

  before do
    sign_in user
    get :edit, id: program.id
  end

  it 'finds the program' do
    expect(assigns(:program)).to eq(program)
  end

  it 'renders edit template' do
    expect(response).to render_template(:edit)
  end
end

describe ProgramsController, 'PUT#update' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }

  before { sign_in user }

  context 'when has valid params' do
    before { put :update, id: program.id, program: FactoryGirl.attributes_for(:program) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { put :update, id: program.id, program: FactoryGirl.attributes_for(:program, name: nil) }

    it 'renders edit template' do
      expect(response).to render_template(:edit)
    end
  end
end

describe ProgramsController, 'DELETE#destroy' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }

  before { sign_in user }

  it 'deletes the program' do
    program #create factory

    expect{
      delete :destroy, id: program.id
    }.to change(Program, :count).by(-1)
  end

  it 'redirects to programs path' do
    delete :destroy, id: program.id

    expect(response).to redirect_to(programs_path)
  end
end
