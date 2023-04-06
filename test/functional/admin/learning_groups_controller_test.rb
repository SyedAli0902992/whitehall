require "test_helper"
class Admin::LearningGroupsControllerTest < ActionController::TestCase
  setup do
    login_as :writer
    @current_user.permissions << "Preview design system"
  end
  should_be_an_admin_controller
  should_allow_creating_of :learning_group
  should_allow_editing_of :learning_group
end