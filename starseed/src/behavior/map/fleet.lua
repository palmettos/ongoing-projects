local BT = require 'libs.bt.behaviour_tree'

local FleetBehavior = BT:new()

local isAreaSafe = BT.Task:new({
    run = function(task, fleet)
        --local items = fleet.collision:querySurroundings(100)
        task:success()
        return
    end
})

local setRandomDestination = BT.Task:new({
    run = function(task, fleet)

        if fleet.movement.moving then
            task:success()
            return
        end

        if not fleet.movement.waiting then

            local rx, ry
            rx = rand(-1000, 1000)
            ry = rand(-1000, 1000)
            
            if (
                   rx + fleet.position.x > fleet.bump.maxDist
                or rx + fleet.position.x < -fleet.bump.maxDist 
            ) then
                rx = -rx
            end

            if (
                   ry + fleet.position.y > fleet.bump.maxDist
                or ry + fleet.position.y < -fleet.bump.maxDist
            ) then
                ry = -ry
            end

            fleet:emit (
                'add_fleet_point_destination',
                rx + fleet.position.x,
                ry + fleet.position.y,
                fleet
            )

            fleet.movement.moving = true

            task:success()
            return
        end

        task:fail()
        return

    end
})

local idleWait = BT.Task:new({
    run = function(task, fleet)

        if fleet.movement.waiting then
            task:success()
            return
        end

		if not fleet.movement.moving then
			local roll = rand(1, 100)
            if roll > 50 then
				fleet.movement.waiting = true

                local duration = rand(0, 4) + rand()
                timer.after (
                    duration,
                    function()
                        fleet.movement:reset()
                    end
                )

				task:success()
				return
            end
        end

		task:fail()
		return

    end
})

FleetBehavior.tree = BT.Priority:new({
	-- Priority Selector: root node priority selector
	---- success: a child called success
	---- fail: no children called success
	--__
		-- Sequence: idle sequence
		---- success: all children called success
		---- fail: a child called fail
		--__
			-- Task: check if area is safe
			---- success: query rect contains no enemies
			---- fail: query rect contains enemies
		--__
			-- Priority Selector: idle/patrol
			---- success: a child called success
			---- fail: never fails; one child always succeeds
			--__
				-- Task: randomly wait idly for a few seconds
				---- success: rolled to wait idle or already idle
				---- fail: roll failed or already patrolling
			--__
				-- Task: set random coord to move to
				---- success: set random coord to move to
				---- fail: never fails
	--__
		-- Priority Selector: fight or flight
		---- success: a child called success
		---- fail: never fails; one child always succeeds
		--__
			-- Sequence: fight
			---- success: all children called success
			---- fail: a child called fail
			--__
				-- Task: check targets' strengths
				---- success: all targets' strengths <= self strength
				---- fail: any target's strength > self strength
			--__
				-- Task: set goal coord to target coord
				---- success: has target or set goal coord to target
				---- fail: never fails
		--__
			-- Task: flight
			---- success: set goal coord away from strongest target
			---- fail: never fails

	nodes = {
        BT.Sequence:new({
            nodes = {

                isAreaSafe,

                BT.Priority:new({
                    nodes = {
                        idleWait,
                        setRandomDestination
                    }
                })

            }
        })
	}
})

return FleetBehavior