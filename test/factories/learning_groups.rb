FactoryBot.define do
  factory :learning_group, class: LearningGroup, parent: :edition do
    title { "learning-group-title" }
    summary { "learning-group-summary" }
    body { "learning-group-body" }
  end
end