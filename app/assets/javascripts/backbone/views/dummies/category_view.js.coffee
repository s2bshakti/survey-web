SurveyBuilder.Views.Dummies ||= {}

# Represents a dummy category on the DOM
class SurveyBuilder.Views.Dummies.CategoryView extends Backbone.View
  initialize: (model) ->
    this.model = model
    this.sub_questions = []
    this.template = $('#dummy_category_template').html()
    this.model.dummy_view = this
    this.model.on('change', this.render, this)
    this.model.on('change:errors', this.render, this)
    this.model.on('change:preload_sub_questions', this.preload_sub_questions)

  render: ->
    this.model.set('content', I18n.t('js.untitled_category')) if _.isEmpty(this.model.get('content'))
    data = this.model.toJSON().category
    data = _(data).extend({ question_number: this.model.question_number })
    $(this.el).html('<div class="dummy_category_content">' + Mustache.render(this.template, data) + '</div>')
    $(this.el).addClass("dummy_category")

    $(this.el).children(".dummy_category_content").click (e) =>
      @show_actual(e)

    $(this.el).children('.dummy_category_content').children(".delete_category").click (e) => @delete(e)

    group = $("<div class='sub_question_group'>")
    _(this.sub_questions).each (sub_question) =>
      #group.sortable({items: "> div", update: @reorder_questions})
      group.append(sub_question.render().el)
    
    $(this.el).append(group) unless _(this.sub_questions).isEmpty()

    return this

  delete: ->
    this.model.destroy()

  add_sub_question: (sub_question_model) =>
    sub_question_model.on('destroy', this.delete_sub_question, this)
    type = sub_question_model.get('type')
    question = SurveyBuilder.Views.QuestionFactory.dummy_view_for(type, sub_question_model)
    this.sub_questions.push question
    this.render()

  preload_sub_questions: (sub_question_models) =>
    _.each(sub_question_models, (sub_question_model) =>
      this.add_sub_question(sub_question_model)
    )

  delete_sub_question: (sub_question_model) ->
    view = sub_question_model.dummy_view
    @sub_questions = _(@sub_questions).without(view)
    view.remove()
    this.trigger('destroy:sub_question')

  show_actual: (event) ->
    $(this.el).trigger("dummy_click")
    $(this.model.actual_view.el).show()
    $(this.el).children('.dummy_category_content').addClass("active")
    $(this.el).trigger("settings_pane_move")

  unfocus: ->
    $(this.el).children('.dummy_category_content').removeClass("active")
    _(this.sub_questions).each (sub_question) =>
      sub_question.unfocus()
