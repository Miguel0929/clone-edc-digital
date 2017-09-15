class QuizProgramsController < ApplicationController
	before_action :set_chapter
	before_action :authenticate_user!
	before_action :set_chapter_content, only: [:show,:destroy,:edit,:update,:clone]

	add_breadcrumb "EDCDIGITAL", :root_path
  add_breadcrumb "Programas", :programs_path

  def new
    @quiz=Quiz.new
  	add_breadcrumb @chapter.program.name, program_path(@chapter.program)
   	add_breadcrumb "<a class='active' href='#{new_chapter_quiz_program_path(@chapter)}'>Nuevo contenido</a>".html_safe
  end

  def create
    @quiz=Quiz.new(quiz_params)
    @quiz.tipo=0
  	if @quiz.save
      @chapter.quizzes << @quiz
  		#QueueNotification.create(category: 2, program: @chapter.program.id, url: dashboard_program_url(@chapter.program), detail: "up-lesson-#{@lesson.id}")
      redirect_to chapter_quiz_program_path(@chapter, @quiz.chapter_content), notice: "Se agrego exitosamente el examen #{@quiz.name}"
    else
      render :new
    end
  end

  def destroy
  	@chapter_content.destroy
  	chapter_contents = @chapter.chapter_contents.map{ |cp| cp.id }
    chapter_contents.each_with_index do |id, index|
      ChapterContent.find(id).update_attributes({position: index + 1})
    end

    redirect_to @chapter.program, notice: "Se eliminó exitosamente el examen"
  end

  def show   
    @quiz=@chapter_content.model
    @quiz_question=QuizQuestion.new
    add_breadcrumb @chapter.program.name, program_path(@chapter.program) 
    add_breadcrumb "<a class='active' href='#{chapter_quiz_program_path(@chapter, @chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe
  end

  def edit
    add_breadcrumb @chapter.program.name, program_path(@chapter.program)
    add_breadcrumb "<a class='active' href='#{edit_chapter_quiz_program_path(@chapter, @chapter_content)}'>#{@chapter_content.model.name}</a>".html_safe	
    @quiz=@chapter_content.model
  end
  def update
    @quiz=@chapter_content.model
    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html { redirect_to program_path(@quiz.chapter_content.chapter.program), notice: 'Quiz actualizado exitosamente.' }
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end
  def clone
    @quiz=@chapter_content.model
    quiz_clone = @quiz.deep_clone do |original, kopy|
      kopy.name = "#{original.name} copia"
      kopy.tipo = 0
      original.quiz_questions.each do |question|
        question_clone= question.deep_clone do |original_q,kopy_q|
          kopy_q.quiz_id=kopy.id
          kopy.quiz_questions << kopy_q
        end  
      end  
    end  

    @chapter.quizzes << quiz_clone
    redirect_to program_path(@chapter.program), notice: "Se creo exitosamente el examen #{quiz_clone.name}"
  end  
  
  private
  def set_chapter
   	@chapter = Chapter.find(params[:chapter_id])
  end
  def set_chapter_content
   	@chapter_content = ChapterContent.find(params[:id])
  end
  def quiz_params
      params.require(:quiz).permit(:name, :description)
    end
end
