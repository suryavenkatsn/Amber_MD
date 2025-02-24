import os

def read_dat_file_filtered_with_header(file_path):
    data = []
    with open(file_path, 'r') as file:
        for i, line in enumerate(file):
            # Split the line into columns by spaces
            columns = line.strip().split()
            
            # Check if it's the first row or the value in the fifth column is greater than 0.2
            if i == 0 or (len(columns) >= 5 and float(columns[4]) > 0.2):
                # Extract and keep only the 1st, 3rd, and 5th columns
                selected_columns = [columns[0], columns[2], columns[4]]
                data.append(selected_columns)
    return data

def write_dat_file(data, output_path):
    with open(output_path, 'w') as output_file:
        for row in data:
            # Convert the list of columns to a space-separated string
            line = ' '.join(row) + '\n'
            output_file.write(line)

# Get the current working directory
current_directory = os.getcwd()

# Process all .dat files in the current directory
for file_name in os.listdir(current_directory):
    if file_name.endswith('.dat'):
        input_file_path = os.path.join(current_directory, file_name)
        output_file_path = os.path.join(current_directory, f'filtered_{file_name}')

        filtered_data_with_header = read_dat_file_filtered_with_header(input_file_path)
        write_dat_file(filtered_data_with_header, output_file_path)

