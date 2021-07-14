defmodule TaskerWeb.TaskControllerTest do
  use TaskerWeb.ConnCase

  import Tasker.Factory

  alias Tasker.Task, as: T

  @create_attrs %{
    "pickup" => %{
      "lat" => latitude(),
      "lon" => longitude()
    },
    "delivery" => %{
      "lat" => latitude(),
      "lon" => longitude()
    }
  }
  @update_attrs %{
    "status" => "assigned"
  }
  @invalid_attrs %{
    "pickup" => %{
      "lat" => latitude(),
      "lon" => longitude()
    }
  }
  @params [
    lat: latitude(),
    lon: longitude(),
    first: 10
  ]
  @invalid_params [
    lat: "wrong",
    lon: "wrong",
    first: 10
  ]

  setup %{conn: conn} do
    user_driver = insert!(:user, "driver")
    user_manager = insert!(:user, "manager")
    {:ok, task} = Tasker.create_task(@create_attrs)

    {:ok,
     conn: put_req_header(conn, "accept", "application/json"),
     user_manager: user_manager,
     user_driver: user_driver,
     task: task}
  end

  describe "no authorization token" do
    test "index renders unauthorized error", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index))
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "index renders unauthorized error with params", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index, @params))
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "index renders unauthorized error with invalid params", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index, @invalid_params))
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "create renders unauthorized error", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @create_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "create renders unauthorized error with data is invalid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @invalid_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "update renders unauthorized error", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "update renders unauthorized error with invalid data", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "delete renders unauthorized error", %{conn: conn, task: task} do
      conn = delete(conn, Routes.task_path(conn, :delete, task))
      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  describe "authorized as manager" do
    setup [:authorize_as_manager]

    test "index renders unsorted tasks", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index))
      assert json_response(conn, 200)["tasks"] != []
    end

    test "index renders sorted tasks", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index, @params))
      assert json_response(conn, 200)["tasks"] != []
    end

    test "index renders errors with invalid params", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index, @invalid_params))
      assert json_response(conn, 400)["errors"] != %{}
    end

    test "create renders task when data is valid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.task_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "status" => "new"
             } = json_response(conn, 200)
    end

    test "create renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end

    test "update renders errors when data is valid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "update renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "deletes chosen task", %{conn: conn, task: task} do
      conn = delete(conn, Routes.task_path(conn, :delete, task))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.task_path(conn, :show, task))
      end
    end
  end

  describe "authorized as driver" do
    setup [:authorize_as_driver]

    test "index renders unsorted tasks", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index))
      assert json_response(conn, 200)["tasks"] != []
    end

    test "index renders sorted tasks", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index, @params))
      assert json_response(conn, 200)["tasks"] != []
    end

    test "index renders errors with invalid params", %{conn: conn} do
      conn = get(conn, Routes.task_path(conn, :index, @invalid_params))
      assert json_response(conn, 400)["errors"] != %{}
    end

    test "create renders errors when data is valid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @create_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "create renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.task_path(conn, :create), task: @invalid_attrs)
      assert json_response(conn, 401)["errors"] != %{}
    end

    test "update renders task when data is valid", %{conn: conn, task: %T{id: id} = task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)

      conn = get(conn, Routes.task_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "status" => "assigned"
             } = json_response(conn, 200)
    end

    test "update renders errors when data is invalid", %{conn: conn, task: task} do
      conn = put(conn, Routes.task_path(conn, :update, task), task: @invalid_attrs)
      assert json_response(conn, 400)["errors"] != %{}
    end

    test "delete renders errors", %{conn: conn, task: task} do
      conn = delete(conn, Routes.task_path(conn, :delete, task))
      assert json_response(conn, 401)["errors"] != %{}
    end
  end

  # describe "update user" do
  #   setup [:create_user]

  #   test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
  #     conn = put(conn, Routes.task_path(conn, :update, user), user: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, Routes.task_path(conn, :show, id))

  #     assert %{
  #              "id" => id,
  #              "age" => 43,
  #              "name" => "some updated name"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, user: user} do
  #     conn = put(conn, Routes.task_path(conn, :update, user), user: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete user" do
  #   setup [:create_user]

  #   test "deletes chosen user", %{conn: conn, user: user} do
  #     conn = delete(conn, Routes.task_path(conn, :delete, user))
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, Routes.task_path(conn, :show, user))
  #     end
  #   end
  # end

  defp authorize_as_manager(%{conn: conn, user_manager: user}) do
    conn = put_req_header(conn, "authorization", "Bearer " <> user.token.value)
    %{conn: conn}
  end

  defp authorize_as_driver(%{conn: conn, user_driver: user}) do
    conn = put_req_header(conn, "authorization", "Bearer " <> user.token.value)
    %{conn: conn}
  end

  # defp create_task(_) do
  #   user = fixture(:task)
  #   %{task: task}
  # end
end
