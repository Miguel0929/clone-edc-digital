require 'rails_helper'

describe ChaptersController, 'GET#new' do
  let(:user) { FactoryGirl.create(:user) }
  let(:program) { FactoryGirl.create(:program) }

  before do
    sign_in user
    get :new, program_id: program.id
  end

  it 'creates a new Chapter instance' do
    expect(assigns(:chapter)).to be_a_new(Chapter)
  end

  it 'renders new template' do
    expect(response).to render_template(:new)
  end
end

describe ChaptersController, 'POST#create' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }

  before { sign_in user }

  context 'when has valid params' do
    before { post :create, program_id: program.id, chapter: FactoryGirl.attributes_for(:chapter) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { post :create, program_id: program.id, chapter: FactoryGirl.attributes_for(:chapter, name: nil) }

    it 'renders new template' do
      expect(response).to render_template(:new)
    end
  end
end

describe ChaptersController, 'GET#edit' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  before do
    sign_in user
    get :edit, program_id: program.id, id: chapter.id
  end

  it 'finds the chapter' do
    expect(assigns(:chapter)).to eq(chapter)
  end

  it 'renders edit template' do
    expect(response).to render_template(:edit)
  end
end

describe ChaptersController, 'PUT#update' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  before { sign_in user }

  context 'when has valid params' do
    before { put :update, program_id: program.id, id: chapter.id, chapter: FactoryGirl.attributes_for(:chapter) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { put :update, program_id: program.id, id: chapter.id, chapter: FactoryGirl.attributes_for(:chapter, name: nil) }

    it 'renders edit template' do
      expect(response).to render_template(:edit)
    end
  end
end

describe ChaptersController, 'DELETE#destroy' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  before { sign_in user }

  it 'deletes the program' do
    chapter #create factory

    expect{
      delete :destroy, program_id: program.id, id: chapter.id
    }.to change(Chapter, :count).by(-1)
  end

  it 'redirects to programs path' do
    delete :destroy, program_id: program.id, id: chapter.id

    expect(response).to redirect_to(program)
  end
end
