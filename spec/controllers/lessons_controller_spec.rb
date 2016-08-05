require 'rails_helper'

describe LessonsController, 'GET#new' do
  let(:user) { FactoryGirl.create(:user) }
  let(:chapter) { FactoryGirl.create(:chapter) }

  before do
    sign_in user
    get :new, chapter_id: chapter.id
  end

  it 'creates a new Lesson instance' do
    expect(assigns(:lesson)).to be_a_new(Lesson)
  end

  it 'renders new template' do
    expect(response).to render_template(:new)
  end
end

describe LessonsController, 'POST#create' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }

  before { sign_in user }

  context 'when has valid params' do
    before { post :create, chapter_id: chapter.id, lesson: FactoryGirl.attributes_for(:lesson) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { post :create, chapter_id: chapter.id, lesson: FactoryGirl.attributes_for(:lesson, content: nil) }

    it 'renders new template' do
      expect(response).to render_template(:new)
    end
  end
end

describe LessonsController, 'GET#edit' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:lesson) { FactoryGirl.create(:lesson) }

  before do
    sign_in user
    get :edit, chapter_id: chapter.id, id: lesson.id
  end

  it 'finds the lesson' do
    expect(assigns(:lesson)).to eq(lesson)
  end

  it 'renders edit template' do
    expect(response).to render_template(:edit)
  end
end

describe LessonsController, 'PUT#update' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:lesson) { FactoryGirl.create(:lesson) }

  before { sign_in user }

  context 'when has valid params' do
    before { put :update, chapter_id: chapter.id, id: lesson.id, lesson: FactoryGirl.attributes_for(:lesson) }

    it 'redirect to program' do
      expect(response).to redirect_to(program)
    end
  end

  context 'when has not valid params' do
    before { put :update, chapter_id: chapter.id, id: lesson.id, lesson: FactoryGirl.attributes_for(:lesson, content: nil) }

    it 'renders edit template' do
      expect(response).to render_template(:edit)
    end
  end
end

describe LessonsController, 'DELETE#destroy' do
  let(:user) { FactoryGirl.create(:user)}
  let(:program) { FactoryGirl.create(:program) }
  let(:chapter) { FactoryGirl.create(:chapter, program: program) }
  let(:lesson) { FactoryGirl.create(:lesson) }

  before { sign_in user }

  it 'deletes the lesson' do
    lesson #create factory

    expect{
      delete :destroy, chapter_id: chapter.id, id: lesson.id
    }.to change(Lesson, :count).by(-1)
  end

  it 'redirects to programs path' do
    delete :destroy, chapter_id: chapter.id, id: lesson.id

    expect(response).to redirect_to(program)
  end
end
