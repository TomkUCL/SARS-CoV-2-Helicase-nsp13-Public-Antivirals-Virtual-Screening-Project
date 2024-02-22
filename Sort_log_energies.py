# Prompt user for input file
input_file = input("Enter the name of the input file: ")

# Read the data from the provided text
with open(input_file, "r") as file:
    lines = file.readlines()

# Parse the data into a dictionary
ligands = {}
for line in lines:
    model, energy = line.split("\t")
    ligands[model] = float(energy.replace(" kcal/mol\n", ""))

# Sort the ligands by energy values
sorted_ligands = sorted(ligands.items(), key=lambda x: x[1])

# Output the sorted ligands with header
print("Vina docking scores: best to worst")
for model, energy in sorted_ligands:
    print(f"{model}\t{energy} kcal/mol")
