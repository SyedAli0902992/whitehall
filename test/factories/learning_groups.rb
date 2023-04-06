FactoryBot.define do
  factory :learning_group, class: LearningGroup, parent: :edition_with_organisations do
    title { "learning-group-title" }
    summary { "learning-group-summary" }
    body { "learning-group-body" }
  end
end