import subprocess

# Set the path to the CLI application and its options as a list of arguments
APP_COMMAND = ["ncs_cli", "-C", "-u", "ncsadmin"]

# Define a list of commands to pass to the CLI application
commands = [
    "config terminal",
    "load merge CMD",
    "commit dry-run",
    "exit",
]

# Define the command you want to pass as an argument
CMD = "test"

# Combine the commands with the provided CMD
commands[1] = commands[1].replace("CMD", CMD)

# Run the CLI application and capture the output
try:
    process = subprocess.Popen(APP_COMMAND, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out, err = process.communicate(input="\n".join(commands))
    
    if process.returncode == 0:
        print("Command executed successfully.")
        print("Output:")
        print(out)
    else:
        print(f"Error: {err}")
except Exception as e:
    print(f"Error: {e}")
