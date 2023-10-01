import subprocess
import re


class CiscoNso:
    def load_merge_xml_file_and_return_output(self, load_xml):
        """
        Constructs the command sequance to send to ncs_cli to load an xml file
        which is passed as an argument. File path of the XML files should be in
        the relative path ./config_files/ directory
        """
        # Set the path to the CLI application and its options as a list of
        # arguments
        app_command = ["ncs_cli", "-C", "-u", "ncsadmin"]

        # Define a list of commands to pass to the CLI application
        commands = [
            "config terminal",
            f"load merge {load_xml}",
            "commit dry-run",
            "exit",
        ]

        # Run the CLI application and capture the output
        try:
            process = subprocess.Popen(
                app_command,
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            out, err = process.communicate(input="\n".join(commands))

            if process.returncode == 0:
                # Check for consistency in the output
                is_consistent, message = self.is_consistent(out)
                # Include the log in the return value
                return is_consistent, message, out
            else:
                # Include the log in the return value
                return False, f"Error: {err}", out
        except Exception as e:
            # Return an empty log in case of an exception
            return False, f"Error: {e}", ''

    def is_consistent(self, output):
        # Split the output into lines
        lines = output.split('\n')

        # Initialize variables for + and - indicators
        plus_seen = False
        minus_seen = False
        # Iterate through the lines
        for line in lines:
            cleaned_line = line.strip()
            if cleaned_line.startswith('+'):
                plus_seen = True
            elif cleaned_line.startswith('-'):
                minus_seen = True

        # Determine consistency based on indicators and return appropriate
        # message
        if plus_seen and minus_seen:
            message = "Configuration is applied but not consistent"
            return False, message
        elif plus_seen:
            message = "Configuration is not applied"
            return False, message
        elif minus_seen:
            message = "Something is wrong, why are we deleting only"
            return False, message
        else:
            message = "Configuration is applied and consistent"
            return True, message
