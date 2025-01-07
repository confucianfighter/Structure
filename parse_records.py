import re
import csv
from datetime import datetime

# 1) Define the psych meds (base names).
#    We only treat them as "the same med" if the route/form is the same.
#    For example, "BUPROPION HCL 75MG TAB" and "BUPROPION HCL 300MG TAB"
#    become "BUPROPION (TAB)", but "BUPROPION HCL 150MG 24HR SA TAB"
#    might be "BUPROPION (24HR SA TAB)" if you want to differentiate.

PSYCH_MEDS_BASE = [
    "AMPHETAMINE/DEXTROAMPHET",
    "ARIPIPRAZOLE",
    "ATOMOXETINE",
    "BENZTROPINE",
    "BUPROPION",
    "BUSPIRONE",
    "CARBAMAZEPINE",
    "CLONIDINE",
    "DIVALPROEX",
    "DOXEPIN",
    "ESCITALOPRAM",
    "HYDROXYZINE",
    "LAMOTRIGINE",
    "LURASIDONE",
    "MELATONIN",
    "NALTREXONE",
    "NICOTINE",
    "OLANZAPINE",
    "PAROXETINE",
    "PROPRANOLOL",
    "QUETIAPINE",
    "RISPERIDONE",
    "SERTRALINE",
    "TOPIRAMATE",
    "TRAZODONE",
    "TRIHEXYPHENIDYL",
]

def normalize_med_name(raw_name):
    """
    Given something like: "BUPROPION HCL 75MG TAB"
    1) Convert to uppercase for matching
    2) Check if it starts with or contains any of the psych base names
    3) Extract the delivery form (e.g. TAB, CAP, 24HR SA TAB, etc.)
    4) Return a standardized string, like "BUPROPION (TAB)"

    If it doesn't match any psych base name, return None.
    """
    raw_upper = raw_name.upper()

    # Find which base name is present
    found_base = None
    for base in PSYCH_MEDS_BASE:
        # Compare in uppercase
        if base in raw_upper:
            found_base = base
            break
    if not found_base:
        return None  # not a psych med we care about

    # Attempt to extract some route or form info
    pattern_form = r"(\d{1,2}HR\s+SA\s+TAB|EC\s+CAP|SA\s+TAB|TAB|CAP|PATCH|SUSP|SOLUTION)"
    matches = re.findall(pattern_form, raw_upper)
    if matches:
        form_str = matches[-1]
    else:
        form_str = "UNKFORM"

    return f"{found_base} ({form_str})"

def parse_last_filled_on(text_line):
    """
    Parse the "Last Filled On" date and return it in 'YYYY-MM' format.
    """
    match = re.search(r"Last Filled On:\s+(\d{1,2}\s+\w{3}\s+\d{4})", text_line)
    if match:
        date_str = match.group(1)
        try:
            dt = datetime.strptime(date_str, "%d %b %Y")
            return dt.strftime("%Y-%m")
        except ValueError:
            return None
    return None

def parse_instructions(text_block):
    """
    Extract medication name, last filled date, and dosage from a text block.
    """
    med_match = re.search(r"Medication:\s+([^\n]+)", text_block, re.IGNORECASE)
    if not med_match:
        return None
    raw_med_name = med_match.group(1).strip()
    norm_name = normalize_med_name(raw_med_name)
    if not norm_name:
        return None

    month_str = parse_last_filled_on(text_block)
    if not month_str:
        return None

    ds_match = re.search(r"Days Supply:\s+(\d+)", text_block)
    days_supply = ds_match.group(1) if ds_match else "30"

    mg_match = re.search(r"(\d+(\.\d+)?mg)", raw_med_name, re.IGNORECASE)
    mg_str = mg_match.group(1).upper().replace("MG", "mg") if mg_match else "??mg"

    instr_match = re.search(r"Instructions:\s+([^\n]+)", text_block, re.IGNORECASE)
    dosage_str = mg_str + " / " + days_supply + "d"
    if instr_match:
        instructions_text = instr_match.group(1).strip().upper()
        if "TWICE" in instructions_text:
            dosage_str = "2x" + mg_str + " / " + days_supply + "d"
        elif "THREE TIMES" in instructions_text:
            dosage_str = "3x" + mg_str + " / " + days_supply + "d"

    return (norm_name, month_str, dosage_str)

def parse_entire_text(raw_text):
    """
    Parse the entire raw text into a dictionary of medications by month.
    """
    chunks = raw_text.split("Medication:")
    meds_dict = {}

    for chunk in chunks:
        block = "Medication:" + chunk
        parsed = parse_instructions(block)
        if not parsed:
            continue
        med_name, month_str, dosage_str = parsed

        if med_name not in meds_dict:
            meds_dict[med_name] = {}

        if month_str not in meds_dict[med_name]:
            meds_dict[med_name][month_str] = dosage_str
        else:
            meds_dict[med_name][month_str] += " + " + dosage_str

    return meds_dict

def generate_months_list(start_year=2014, start_month=1, end_year=2025, end_month=1):
    """
    Generate a list of YYYY-MM strings from start to end dates.
    """
    months_list = []
    cur_year, cur_month = start_year, start_month

    while True:
        months_list.append(f"{cur_year:04d}-{cur_month:02d}")
        if cur_year == end_year and cur_month == end_month:
            break
        cur_month += 1
        if cur_month > 12:
            cur_month = 1
            cur_year += 1

    return months_list

def produce_csv(meds_dict, csv_filename, start_year=2014, start_month=1, end_year=2025, end_month=1):
    """
    Write the medications dictionary to a CSV file.
    """
    all_med_names = sorted(meds_dict.keys())
    month_list = generate_months_list(start_year, start_month, end_year, end_month)

    header = ["Month"] + all_med_names
    rows = []

    for month_str in month_list:
        row_data = [month_str]
        for med in all_med_names:
            row_data.append(meds_dict[med].get(month_str, ""))
        rows.append(row_data)

    with open(csv_filename, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(header)
        writer.writerows(rows)

    print(f"CSV written to {csv_filename} with {len(rows)} rows and {len(header) - 1} med columns.")

def main():
    """
    Main function to parse the text and generate a CSV.
    """
    input_file_path = input("Please provide the path to your text file: ").strip()
    output_file_path = input("Please provide the desired path for the output CSV file: ").strip()

    try:
        with open(input_file_path, "r", encoding="utf-8") as file_in:
            raw_text = file_in.read()

        meds_dict = parse_entire_text(raw_text)
        produce_csv(meds_dict, output_file_path, 2014, 1, 2025, 1)
    except FileNotFoundError:
        print(f"Error: The file at {input_file_path} was not found. Please check the path and try again.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == "__main__":
    main()
