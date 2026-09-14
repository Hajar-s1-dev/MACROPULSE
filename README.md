# 🌍 MACROPULSE

### Global Political & Economic Event Intelligence Platform

**MACROPULSE** is a data-driven project designed to collect, analyze, classify, and monitor major political and economic events happening around the world.

The project uses **real-world data from GDELT** to transform large volumes of global event data into structured information that can help identify potentially important geopolitical and economic developments.

---

## 🎯 Project Objective

Every day, thousands of political and economic events happen around the world.

The problem is not finding data — it's understanding **which events actually matter**.

MACROPULSE aims to answer questions such as:

* 🌍 Which countries are involved in major events?
* ⚠️ Which events could create geopolitical risks?
* 📉 Which resources or sectors could potentially be affected?
* 🔥 Which events deserve more attention?
* 📊 What countries or regions are becoming increasingly involved in important events?
* 🕒 How do major events evolve over time?

The goal is to transform **raw global event data → structured intelligence**.

---

## 🧠 How It Works

```text
        🌐 GDELT
           │
           ▼
   ┌─────────────────┐
   │ Data Collection │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ Data Cleaning   │
   │ & Normalization │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ Event Filtering │
   │ & Classification │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ SQL Database    │
   └────────┬────────┘
            │
            ▼
   ┌─────────────────┐
   │ Analysis &      │
   │ Insights        │
   └─────────────────┘
```

---

## 🚀 Main Features

### 🌐 Real-World Data

MACROPULSE retrieves real event data from **GDELT**, allowing the project to work with continuously changing global information rather than static datasets.

### 🧹 Data Processing

Raw event data is processed and normalized before being stored.

The pipeline handles:

* Data extraction
* Cleaning
* Normalization
* Duplicate handling
* Country identification
* Event categorization
* Date/time processing

### 🏷️ Event Classification

The system focuses on **important events** rather than treating every event equally.

Events can be analyzed according to categories such as:

* Politics
* Conflict
* International relations
* Economy
* Trade
* Energy
* Resources
* Security

### 🌍 Country Impact Analysis

MACROPULSE identifies countries involved in events and helps analyze their relationships and potential exposure to major geopolitical developments.

### 📊 SQL-Based Analysis

Structured data is stored in a relational database, making it possible to perform analytical queries such as:

* Most affected countries
* Most frequent event categories
* Events by date
* Country-to-country interactions
* High-impact events
* Historical trends

---

## 🛠️ Technologies

| Technology         | Purpose                             |
| ------------------ | ----------------------------------- |
| 🐍 Python          | Data ingestion and processing       |
| 🗄️ SQL            | Data storage and analytical queries |
| 🌐 GDELT           | Real-world global event data        |
| 🐼 Pandas          | Data manipulation                   |
| 🔗 Requests        | API/data retrieval                  |
| 💻 Git & GitHub    | Version control                     |
| 🪟 Windows / XAMPP | Local development environment       |

---

## 📁 Project Structure

```text
MACROPULSE/
│
├── collector.py
│
├── database/
│   └── ...
│
├── data/
│   └── ...
│
├── analysis/
│   └── ...
│
├── sql/
│   └── ...
│
├── requirements.txt
│
└── README.md
```

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/macropulse.git
cd macropulse
```

### 2. Create a virtual environment

```bash
python -m venv venv
```

### 3. Activate it

**Windows:**

```bash
venv\Scripts\activate
```

### 4. Install dependencies

```bash
pip install -r requirements.txt
```

---

## ▶️ Run the Data Collector

Start the GDELT ingestion process:

```bash
python collector.py
```

The collector retrieves available event data and prepares it for processing and database storage.

---

## 🗄️ Database

MACROPULSE uses a relational database to transform raw event information into structured and queryable data.

The database is designed to support analytical questions such as:

```sql
SELECT country, COUNT(*) AS event_count
FROM events
GROUP BY country
ORDER BY event_count DESC;
```

Example analytical questions:

```sql
-- Most active countries
SELECT country, COUNT(*)
FROM events
GROUP BY country
ORDER BY COUNT(*) DESC;
```

```sql
-- Events by category
SELECT category, COUNT(*)
FROM events
GROUP BY category
ORDER BY COUNT(*) DESC;
```

```sql
-- Recent important events
SELECT *
FROM events
ORDER BY event_date DESC;
```

---

## 📈 Future Improvements

MACROPULSE is designed to evolve into a more advanced data intelligence platform.

Planned improvements include:

* 🤖 Machine Learning-based event classification
* 🧠 NLP analysis of event descriptions
* 📊 Interactive dashboards
* 🌍 Geographical visualization
* ⚠️ Risk scoring
* 📉 Economic impact indicators
* 🔗 Event relationship detection
* 📅 Historical trend analysis
* 🔔 Important-event alerts
* 🧩 Integration with additional global datasets

---

## 🔬 Data Science Perspective

MACROPULSE is not simply a database project.

It represents a complete **data pipeline**:

```text
Raw Data
   ↓
Data Collection
   ↓
Data Cleaning
   ↓
Data Transformation
   ↓
Data Storage
   ↓
Data Analysis
   ↓
Information
   ↓
Potential Intelligence
```

This makes the project relevant to areas such as:

* Data Science
* Data Engineering
* Business Intelligence
* Risk Analysis
* Economics
* Geopolitical Analysis
* Information Systems

---

## 🎓 Academic & Portfolio Purpose

MACROPULSE was developed as a personal project to explore the intersection between:

**Data Science + SQL + Global Economics + Geopolitics**

The project demonstrates practical experience with:

* Real-world datasets
* Data pipelines
* Python
* SQL databases
* Data cleaning
* Data analysis
* Git/GitHub
* API/data-source integration

---

## ⚠️ Disclaimer

MACROPULSE is an experimental analytical project.

The classifications, detected impacts, and potential risks generated by the system should **not be considered official geopolitical or financial predictions**.

The project is intended for educational, analytical, and research purposes.

---

## 👩‍💻 Author

**Hajar Sadry**

Junior Digital Developer
Interested in **Data Science, SQL, Cybersecurity & Technology**

---

## ⭐ Project Vision

> **From global events to structured intelligence.**

MACROPULSE aims to make large-scale global event data easier to understand, analyze, and explore through data engineering and data science.
