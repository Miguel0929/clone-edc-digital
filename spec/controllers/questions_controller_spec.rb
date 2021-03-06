require 'rails_helper'

describe QuestionsController, 'GET#new' do
  let(:user) { FactoryGirl.create(:user) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  before do
    sign_in user
    get :new, chapter_id: chapter.id
  end

  it 'creates a new Question instance' do
    expect(assigns(:question)).to be_a_new(Question)
  end

  it 'renders new template' do
    expect(response).to render_template(:new)
  end
end

describe QuestionsController, 'POST#create' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }

  before { sign_in user }

  context 'when has valid params' do
    before { post :create, chapter_id: chapter.id, question: FactoryGirl.attributes_for(:question) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { post :create, chapter_id: chapter.id, question: FactoryGirl.attributes_for(:question, question_text: nil) }

    it 'renders new template' do
      expect(response).to render_template(:new)
    end
  end
end

describe QuestionsController, 'GET#edit' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:question) { FactoryGirl.create(:question) }

  before do
    sign_in user
    get :edit, chapter_id: chapter.id, id: question.id
  end

  it 'finds the questions' do
    expect(assigns(:question)).to eq(question)
  end

  it 'renders edit template' do
    expect(response).to render_template(:edit)
  end
end

describe QuestionsController, 'PUT#update' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:question) { FactoryGirl.create(:question) }

  before { sign_in user }

  context 'when has valid params' do
    before { put :update, chapter_id: chapter.id, id: question.id, question: FactoryGirl.attributes_for(:question) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { put :update, chapter_id: chapter.id, id: question.id, question: FactoryGirl.attributes_for(:question, question_text: nil) }

    it 'renders edit template' do
      expect(response).to render_template(:edit)
    end
  end
end

describe QuestionsController, 'DELETE#destroy' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:question) { FactoryGirl.create(:question) }

  before { sign_in user }

  it 'deletes the question' do
    question #create factory

    expect{
      delete :destroy, chapter_id: chapter.id, id: question.id
    }.to change(Question, :count).by(-1)
  end

  it 'redirects to programs path' do
    delete :destroy, chapter_id: chapter.id, id: question.id

    expect(response).to redirect_to(program)
  end
end
