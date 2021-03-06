require File.dirname(__FILE__) + '/../test_helper'
require 'tasks_controller'

# Re-raise errors caught by the controller.
class TasksController; def rescue_action(e) raise e end; end

class TasksControllerTest < Test::Unit::TestCase
  fixtures :users
  fixtures :tasks

  def setup
    @controller = TasksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :ludwig
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_task
    assert_difference('Task.count') do
      post :create, :task => { }
    end

    assert_redirected_to task_path(assigns(:task))
  end

  def test_should_show_task
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_task
    put :update, :id => 1, :task => { }
    assert_redirected_to task_path(assigns(:task))
  end

  def test_should_destroy_task
    assert_difference('Task.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to tasks_path
  end
end
