function Create(self)
	self.disintegrationStrength = 50;
	self.EffectRotAngle = self.Vel.AbsRadAngle;
	--Check backward (second argument) on the first frame as the projectile might be bouncing off something immediately
	PulsarDissipate(self, true);
	
	self.trailPar = CreateMOPixel("Techion Pulse Shot Trail Glow");
	self.trailPar.Pos = self.Pos - (self.Vel * rte.PxTravelledPerFrame);
	self.trailPar.Vel = self.Vel * 0.1;
	self.trailPar.Lifetime = 60;
	MovableMan:AddParticle(self.trailPar);
end
function Update(self)
	self.ToSettle = false;
	if self.explosion then
		self.ToDelete = true;
	else
		PulsarDissipate(self, false);
		if self.trailPar and MovableMan:IsParticle(self.trailPar) then
			self.trailPar.Pos = self.Pos - Vector(self.Vel.X, self.Vel.Y):SetMagnitude(6);
			self.trailPar.Vel = self.Vel * 0.5;
			self.trailPar.Lifetime = self.Age + TimerMan.DeltaTimeMS;
		else
			self.trailPar = nil;
		end
	end
	self.EffectRotAngle = self.Vel.AbsRadAngle;
end
function PulsarDissipate(self, inverted)

	local trace = inverted and Vector(-self.Vel.X, -self.Vel.Y):SetMagnitude(GetPPM()) or Vector(self.Vel.X, self.Vel.Y):SetMagnitude(self.Vel.Magnitude * rte.PxTravelledPerFrame + 1);
	local hit;
	local hitPos = Vector();
	local skipPx = math.sqrt(self.Vel.Magnitude) * 0.5;

	local moid =	SceneMan:CastObstacleRay(self.Pos, trace, hitPos, Vector(), self.ID, self.Team, rte.airID, skipPx) >= 0
					and SceneMan:GetMOIDPixel(hitPos.X, hitPos.Y) or self.HitWhatMOID;
	
	if moid ~= rte.NoMOID then
		local mo = MovableMan:GetMOFromID(moid);
		if mo then
			hit = true;

			local melt = CreateMOPixel("Disintegrator");
			melt.Pos = self.Pos;
			melt.Team = self.Team;
			melt.Sharpness = mo.RootID;
			melt.PinStrength = self.disintegrationStrength or 1;
			MovableMan:AddMO(melt);
		end
	else
		local penetration = self.Mass * self.Sharpness * self.Vel.Magnitude;
		if SceneMan:GetMaterialFromID(SceneMan:GetTerrMatter(hitPos.X, hitPos.Y)).StructuralIntegrity > penetration then
			hit = true;
		end
	end
	if hit or math.abs(math.sin(self.Vel.AbsRadAngle - self.lastVel.AbsRadAngle)) > 0.1 or self.Vel.Magnitude < self.lastVel.Magnitude * 0.5 then
		local offset = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(skipPx);
		self.explosion = CreateAEmitter("Techion.rte/Laser Dissipate Effect");
		self.explosion.Pos = hitPos - offset;
		self.explosion.RotAngle = offset.AbsRadAngle;
		self.explosion.Team = self.Team;
		self.explosion.Vel = offset;
		MovableMan:AddParticle(self.explosion);
	end
	self.lastVel = Vector(self.Vel.X, self.Vel.Y);
end
--[[ To-do: Use this system instead
function OnCollideWithMO(self, mo, parentMO)
	self.explosion = CreateAEmitter("Techion.rte/Laser Dissipate Effect");
	self.explosion.Pos = self.Pos;
	self.explosion.RotAngle = self.Vel.AbsRadAngle;
	self.explosion.Team = self.Team;
	self.explosion.Vel = self.Vel;
	MovableMan:AddParticle(self.explosion);
end
function OnCollideWithTerrain(self, terrainID)
	self.explosion = CreateAEmitter("Techion.rte/Laser Dissipate Effect");
	self.explosion.Pos = self.Pos;
	self.explosion.RotAngle = self.Vel.AbsRadAngle;
	self.explosion.Team = self.Team;
	self.explosion.Vel = self.Vel;
	MovableMan:AddParticle(self.explosion);
end]]--