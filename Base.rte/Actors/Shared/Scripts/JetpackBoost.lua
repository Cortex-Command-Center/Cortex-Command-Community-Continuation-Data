-- HEAT-like jetpack boost system by filipex
-- adapted/standardized by pawnis 13/4/2023

function Create(self)

	self.jetpackBoostSound = CreateSoundContainer("Jetpack Boost Sound", "Base.rte");

	self.boosterReady = true;
	self.boosterTimer = Timer();
	self.boosterAIDelay = 6000;
	
	self.attemptedBoost = false;

	self.parent = ToActor(self:GetRootParent());

end

function Update(self)

	-- sanity check, don't know what strange jetpack switching stuff is out there
	self.parent = IsActor(self:GetRootParent()) and ToActor(self:GetRootParent()) or nil;

	if self.parent then
	
		local controller = self.parent:GetController();
	
		local crouching = controller:IsState(Controller.BODY_CROUCH);
		local boosting = false;
		
		if self.parent:IsPlayerControlled() then
			boosting = crouching and controller:IsState(Controller.BODY_JUMPSTART);
		elseif self.boosterTimer:IsPastSimMS(self.boosterAIDelay) then
			boosting = controller:IsState(Controller.BODY_JUMPSTART) and SceneMan:ShortestDistance(self.Pos,self:GetLastAIWaypoint(),SceneMan.SceneWrapsX).Y < -5;
		end
		
		self.jetpackBoostSound.Pos = self.Pos;
		
		if boosting then 
			if self.boosterReady and not self.attemptedBoost then
		
				self.attemptedBoost = true;
			
				self.jetpackBoostSound:Play(self.Pos);
				
				self.parent.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(-self.RotAngle);
				self.parent.Vel = Vector(self.Vel.X, self.Vel.Y * 0.5);
				self.parent.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(self.RotAngle);
				
				self.parent.Vel = self.Vel + Vector(0, -7):RadRotate(self.RotAngle);
				self.boosterReady = false;
				
				self.boosterTimer:Reset();
				
				--local offset = Vector(self.EmissionOffset.X, self.EmissionOffset.Y)
				
				local emitter = CreateAEmitter("Smoke Trail Medium");
				emitter.Lifetime = 2000;
				self:AddAttachable(emitter);
				
			end
			
		elseif not self.boosterReady and self.boosterTimer:IsPastSimMS(500) then
			
			local groundCheckVector = Vector(0, self.parent.Radius*2);
			local groundCheckRay = SceneMan:CastObstacleRay(self.Pos, groundCheckVector, Vector(), Vector(), 0, self.Team, 0, 4);
			
			if groundCheckRay ~= -1 then
				self.boosterReady = true
			end
				
		else
			self.attemptedBoost = false;
		end
	end

end