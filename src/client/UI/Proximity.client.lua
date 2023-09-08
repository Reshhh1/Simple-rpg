local ProximityService = game:GetService("ProximityPromptService")

ProximityService.PromptShown:Connect(function(prompt, inputType)
	prompt.BillboardGui.Enabled = true	
	
end)

ProximityService.PromptHidden:Connect(function(prompt)
	prompt.BillboardGui.Enabled = false	
end)

ProximityService.PromptButtonHoldBegan:Connect(function(prompt)

end)

ProximityService.PromptButtonHoldEnded:Connect(function(prompt)

end)