import os
import pandas as pd
import multiprocessing


def process_file(file_path):
    return pd.read_csv(file_path, usecols=['language'])


def main(data_dir, output_file):
    # Get the list of all CSV files
    filenames = [os.path.join(data_dir, filename) for filename in os.listdir(data_dir)
                 if filename.endswith(".csv")]

    # Determine number of CPU cores
    num_cores = multiprocessing.cpu_count()

    # Create a multiprocessing pool
    with multiprocessing.Pool(processes=num_cores) as pool:
        dataframes = pool.map(process_file, filenames)

    # Concatenate all DataFrames
    combined_df = pd.concat(dataframes)

    # Group by language and count occurrences
    language_counts = combined_df['language'].value_counts().reset_index()
    language_counts.columns = ['language', 'count']

    # Output the final counts to a CSV file
    language_counts.to_csv(output_file, index=False)


if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    data_dir = os.path.join(script_dir, "../results")
    output_file = ("aggregated_languages.csv")
    main(data_dir, output_file)
