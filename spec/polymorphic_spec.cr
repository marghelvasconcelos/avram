require "./spec_helper"

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

  it "validates that at most one polymorphic belongs to is allowed" do
    operation = PolymorphicEvent::SaveOperation.create(task_id: 1, task_list_id: 1) do |operation, _event|
      operation.valid?.should be_false
      operation.task_list_id.errors.should eq(["must be blank"])
    end
  end

  # They must be nullable since only  one can be filled  in at a time.
  # And remind to make migration optional too
  pending "ensure polymorphic associations are optional"

  #  Allow all associations to be nil...maybe. Does that even make sense?
  # Would a comment ever have a nil commentable?
  pending "allow specifying whether the pooymorphic is optional"

  # Make sure it blows up if not preloaded. And allow using ! to skip preloading
  pending "Make sure preloads work as expected"
end
