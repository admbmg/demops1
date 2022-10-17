# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process
