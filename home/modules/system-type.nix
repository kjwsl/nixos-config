{
  # Simple way to determine the system type without complex module evaluation
  # System detection based on checking for darwin (which we know this instance is)
  # For more robust checking, you could add more system types here
  isArm64Darwin = true;  # Hardcoded for this specific machine
  isLinux = false;  # Hardcoded for this specific machine
} 