class QuestionTypeGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def create_rails_model
    template "rails_model.rb", "app/models/#{file_name}.rb"
    template "rails_model_spec.rb", "spec/models/#{file_name}_spec.rb"
  end

  def create_backbone_model
    template "backbone_model.rb", "app/assets/javascripts/backbone/models/#{file_name}_model.js.coffee"
    template "backbone_model_spec.rb", "spec/javascripts/backbone/models/#{file_name}_model_spec.js.coffee"
  end

  def create_backbone_views
    template "backbone_dummy_view.rb", "app/assets/javascripts/backbone/views/dummies/#{file_name}_view.js.coffee"
    template "backbone_actual_view.rb", "app/assets/javascripts/backbone/views/questions/#{file_name}_view.js.coffee"
  end
end