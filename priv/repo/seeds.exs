import Tasker.Factory

Enum.each(1..3, fn _ -> insert!(:user, "manager") end)
Enum.each(1..5, fn _ -> insert!(:user, "driver") end)
Enum.each(1..50, fn _ -> insert!(:task) end)
