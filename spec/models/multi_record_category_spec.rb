require 'spec_helper'

describe MultiRecordCategory do
  it "is a category with type = 'MultiRecordCategory'" do
    MultiRecordCategory.create(:content => "hello")
    category = Category.find_by_content("hello")
    category.should be_a MultiRecordCategory
    category.type.should == "MultiRecordCategory"
  end

  it "doesn't allow nested multi-record categories" do
    parent_mr = MultiRecordCategory.create(:content => "mr")
    expect do
      MultiRecordCategory.create(:content => "child_mr", :category_id => parent_mr.id)
    end.not_to change { MultiRecordCategory.count }
  end

  context "when sorting answers for a response" do
    let(:response) { FactoryGirl.create :response }

    it "returns answers for each of its records" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question, :category => mr_category
      5.times do
        record = Record.create(:response_id => response.id)
        mr_category.records << record
        record.answers << FactoryGirl.create(:answer, :question => question, :response => response)
      end

      mr_category.sorted_answers_for_response(response.id).size.should == 5
    end

    it "includes records belonging only to the specified response" do
      another_response = FactoryGirl.create :response
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question, :category => mr_category

      5.times do
        record = Record.create(:response_id => response.id)
        mr_category.records << record
        record.answers << FactoryGirl.create(:answer, :question => question, :response => response)
      end

      5.times do
        record = Record.create(:response_id => another_response.id)
        mr_category.records << record
        record.answers << FactoryGirl.create(:answer, :question => question, :response => another_response)
      end

      mr_category.sorted_answers_for_response(response.id).size.should == 5      
    end
  end

  context "when creating empty answers for a new response" do
    let(:response) { FactoryGirl.create :response }

    it "creates a new empty record" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      expect {
        mr_category.create_blank_answers(:response_id => response.id)
      }.to change { Record.count }.by 1
    end

    it "creates empty answers for the new record" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question
      mr_category.questions << question

      mr_category.create_blank_answers(:response_id => response.id)
      question.reload.answers.should_not be_empty
    end

    it "doesn't create a record if a record_id is passed in" do
      mr_category = MultiRecordCategory.create(:content => "MR")
      question = FactoryGirl.create :question, :category => mr_category
      record = FactoryGirl.create :record, :response => response, :category => mr_category

      expect do
        mr_category.create_blank_answers(:record_id => record.id, :response_id => response.id)
      end.not_to change { Record.count }
    end
  end

  context "when fetching all child records that belong to a given response" do
    it "fetches all the records with the given response_id" do
      mr_category = MultiRecordCategory.create(:content => "hello")
      record = FactoryGirl.create(:record, :category => mr_category, :response_id => 5)
      record_from_another_Response = FactoryGirl.create(:record, :category => mr_category, :response_id => 6)
      orphan_record = FactoryGirl.create(:record)
      mr_category.records_for_response(5).should == [record]
    end
  end
end
