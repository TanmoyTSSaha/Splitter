# Creative Developer Agent — 10-minute background tick loop
# Separate from react_website_dev loop. Do not run both in one shell unless intentional.

$prompt = @'
Creative Developer loop: Read ai-docs/creative-direction.md, storyboard.md, motion-library.md §I-II (interim for motion-language + scene-choreography), design-system.md, component-library.md, react-website-development-details.md. Implement only scenes with full storyboard + motion-library §II spec. Missing spec → set Blocked in react-website-development-details.md §9.1, escalate Creative/Storyboard/Motion Directors — no undocumented code. No substitutions (fade for camera, static for R3F unless documented fallback). Browser-verify in apps/web before Implemented. Update Implementation Status on change.
'@

Write-Host "Creative Developer Agent loop started. Tick every 600s."
Write-Host "Pattern: AGENT_LOOP_TICK_creative_website_dev"
Write-Host "Stop: Ctrl+C"

while ($true) {
    Start-Sleep -Seconds 600
    Write-Output "AGENT_LOOP_TICK_creative_website_dev {`"prompt`":`"$($prompt -replace '"','\"')`"}"
}
