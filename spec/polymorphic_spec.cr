require "./spec_helper"

include LazyLoadHelpers

private class PolymorphicTask < BaseModel
  table do
    column title : String
  end
end

private class PolymorphicTaskList < BaseModel
  table do
    column title : String
  end
end

private class PolymorphicEvent < BaseModel
  table do
    belongs_to task : PolymorphicTask?
    belongs_to task_list : PolymorphicTaskList?
    polymorphic :eventable, associations: [:task, :task_list]
  end
end

describe "polymorphic belongs to" do
  it "sets up a method for accessing associated record" do
    task = PolymorphicTask::SaveOperation.create!(title: "Use Lucky")
    event = PolymorphicEvent::SaveOperation.create!(task_id: task.id)
    event.eventable.should eq(task)

    task_list = PolymorphicTaskList::SaveOperation.create!(title: "Use Lucky")
    event = PolymorphicEvent::SaveOperation.create!(task_list_id: task_list.id)
    event.eventable.should eq(task_list)
  end

  it "can require preloading" do
    with_lazy_load(enabled: false) do
      expect_raises Avram::LazyLoadError do
        task = PolymorphicTask::SaveOperation.create!(title: "Use Lucky")
        event = PolymorphicEvent::SaveOperation.create!(task_id: task.id)
        event.eventable # should raise
      end
    end
  end

  it "has ! method to allow lazy loading" do
    with_lazy_load(enabled: false) do
      task = PolymorphicTask::SaveOperation.create!(title: "Use Lucky")
      event = PolymorphicEvent::SaveOperation.create!(task_id: task.id)
      event.eventable!.should eq(task)
    end
  end

  it "can preload the polymorphic associations" do
    with_lazy_load(enabled: false) do
      task = PolymorphicTask::SaveOperation.create!(title: "Use Lucky")
      event = PolymorphicEvent::SaveOperation.create!(task_id: task.id)
      event = PolymorphicEvent::BaseQuery.new.preload_eventable.find(event.id)
      event.eventable.should eq(task)

      # Check that it preloads both belongs_to, not just the first
      task_list = PolymorphicTaskList::SaveOperation.create!(title: "Use Lucky")
      event = PolymorphicEvent::SaveOperation.create!(task_list_id: task_list.id)
      event = PolymorphicEvent::BaseQuery.new.preload_eventable.find(event.id)
      event.eventable.should eq(task_list)
    end
  end

  it "validates that at most one polymorphic belongs to is allowed" do
    operation = PolymorphicEvent::SaveOperation.create(task_id: 1, task_list_id: 1) do |operation, _event|
      operation.valid?.should be_false
      operation.task_list_id.errors.should eq(["must be blank"])
    end
  end

  # They must be nullable since only  one can be filled in at a time.
  # And remind to make migration optional too
  pending "ensure defined polymorphic associations are nullable"

  # Allow all associations to be nil...maybe. Does that even make sense?
  # Would a comment ever have a nil commentable?
  pending "allow specifying whether the polymorphic is optional"
end
