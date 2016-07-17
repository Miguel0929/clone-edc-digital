require 'rails_helper'

describe StagesController, 'GET#new' do
  let(:user) { FactoryGirl.create(:user) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  before do
    sign_in user
    get :new, chapter_id: chapter.id
  end

  it 'creates a new Stage instance' do
    expect(assigns(:stage)).to be_a_new(Stage)
  end

  it 'renders new template' do
    expect(response).to render_template(:new)
  end
end

describe StagesController, 'POST#create' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }

  before { sign_in user }

  context 'when has valid params' do
    before { post :create, chapter_id: chapter.id, stage: FactoryGirl.attributes_for(:stage) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { post :create, chapter_id: chapter.id, stage: FactoryGirl.attributes_for(:stage, name: nil) }

    it 'renders new template' do
      expect(response).to render_template(:new)
    end
  end
end

describe StagesController, 'GET#edit' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:stage) { FactoryGirl.create(:stage) }

  before do
    sign_in user
    get :edit, chapter_id: chapter.id, id: stage.id
  end

  it 'finds the stage' do
    expect(assigns(:stage)).to eq(stage)
  end

  it 'renders edit template' do
    expect(response).to render_template(:edit)
  end
end

describe StagesController, 'PUT#update' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:stage) { FactoryGirl.create(:stage) }

  before { sign_in user }

  context 'when has valid params' do
    before { put :update, chapter_id: chapter.id, id: stage.id, stage: FactoryGirl.attributes_for(:stage) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { put :update, chapter_id: chapter.id, id: stage.id, stage: FactoryGirl.attributes_for(:stage, name: nil) }

    it 'renders edit template' do
      expect(response).to render_template(:edit)
    end
  end
end

describe StagesController, 'DELETE#destroy' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:stage) { FactoryGirl.create(:stage) }

  before { sign_in user }

  it 'deletes the stage' do
    stage #create factory

    expect{
      delete :destroy, chapter_id: chapter.id, id: stage.id
    }.to change(Stage, :count).by(-1)
  end

  it 'redirects to programs path' do
    delete :destroy, chapter_id: chapter.id, id: stage.id

    expect(response).to redirect_to(program)
  end
end
