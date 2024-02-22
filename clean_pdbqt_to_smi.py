import os

def filter_unique_descriptors(input_file, output_file):
    unique_descriptors = set()
    with open(input_file, 'r') as f:
        lines = f.readlines()
        for line in lines:
            parts = line.split("\t")
            if len(parts) < 2:  # Check if the line has at least two parts
                continue
            smiles = parts[0]
            descriptor_parts = parts[1].split(" ")
            if len(descriptor_parts) < 2:  # Check if the descriptor has at least two parts
                continue
            descriptor = descriptor_parts[1]  # Extracting descriptor while excluding "untitled_line_XX"
            if descriptor not in unique_descriptors:
                unique_descriptors.add(descriptor)
                # Write SMILES string to a separate .smi file
                with open(f"{descriptor}.smi", 'w') as smile_file:
                    smile_file.write(smiles)

                with open(output_file, 'a') as out_f:
                    out_f.write(f"{smiles}\t{descriptor}\n")  # Added newline character to separate lines

# Get input and output filenames from the user
input_filename = input("Enter the input filename (e.g., input.txt): ")
output_filename = input("Enter the output filename (e.g., output.txt): ")

# Ensure the input file exists
if not os.path.exists(input_filename):
    print("Error: Input file not found.")
else:
    # Call the function
    filter_unique_descriptors(input_filename, output_filename)
    print("SMILES duplicates removed. Result saved to", output_filename)
