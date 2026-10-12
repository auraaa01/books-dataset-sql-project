for name in ["books", "users", "ratings"]:
    with open(f"data/{name}.csv", encoding="utf-8", errors="replace", newline="") as f:
        text = f.read()
    text = text.replace('\\"', '""')
    with open(f"data/{name}_clean.csv", "w", encoding="utf-8", newline="") as f:
        f.write(text)