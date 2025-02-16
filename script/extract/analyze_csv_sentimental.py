import pandas as pd
from transformers import pipeline
import warnings
import logging
from datetime import datetime
import sys
from tqdm import tqdm
import matplotlib.pyplot as plt


warnings.filterwarnings('ignore')
logging.getLogger("transformers.modeling_utils").setLevel(logging.ERROR)


class SentimentAnalyzer:
    def __init__(self):
        """Initialize the sentiment analyzer"""
        self.classifier = pipeline(
            task="sentiment-analysis",
            model="cardiffnlp/twitter-roberta-base-sentiment-latest",
            truncation=True,
            max_length=512,  # Use a value less than or equal to the maximum allowed
            device= 0,
        )

        self.label_mapping = {
            'positive': 'POSITIVE',
            'negative': 'NEGATIVE',
            'neutral': 'NEUTRAL'
        }

    def analyze_text(self, text):
        """Analyze a single text"""
        try:
            if pd.isna(text):  # Check if text is NaN
                return {'sentiment': 'INVALID', 'confidence': 0.0}

            result = self.classifier(str(text))[0]
            return {
                'sentiment': self.label_mapping[result['label']],
                'confidence': round(result['score'], 4)
            }
        except Exception as e:
            print(f"Error analyzing text: {str(e)}")
            return {'sentiment': 'ERROR', 'confidence': 0.0}


def create_visualizations(df):
    """Create and save visualizations of the analysis"""
    # 1. Sentiment Distribution
    plt.figure(figsize=(10, 6))
    sentiment_counts = df['sentiment'].value_counts()
    plt.bar(sentiment_counts.index, sentiment_counts.values)
    plt.title('Distribution of Sentiments')
    plt.xlabel('Sentiment')
    plt.ylabel('Count')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('sentiment_distribution.png')
    plt.close()

    # 2. Confidence Distribution
    plt.figure(figsize=(10, 6))
    plt.hist(df['confidence'], bins=30, edgecolor='black')
    plt.title('Distribution of Confidence Scores')
    plt.xlabel('Confidence Score')
    plt.ylabel('Frequency')
    plt.tight_layout()
    plt.savefig('confidence_distribution.png')
    plt.close()

    # 3. Average Confidence by Sentiment
    plt.figure(figsize=(10, 6))
    avg_confidence = df.groupby('sentiment')['confidence'].mean()
    plt.bar(avg_confidence.index, avg_confidence.values)
    plt.title('Average Confidence by Sentiment')
    plt.xlabel('Sentiment')
    plt.ylabel('Average Confidence')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('confidence_by_sentiment.png')
    plt.close()


def analyze_csv_file(file_path):
    """Analyze all comments in the CSV file"""
    try:
        # Read the CSV file
        print(f"Reading CSV file from: {file_path}")
        df = pd.read_csv(file_path)

        # Print basic information about the dataset
        print("\nDataset Information:")
        print("-" * 50)
        print(f"Total number of rows: {len(df)}")
        print(f"Columns in the file: {', '.join(df.columns)}")

        # Initialize the analyzer
        analyzer = SentimentAnalyzer()

        # Analyze each comment with progress bar
        print("\nAnalyzing comments...")
        results = []
        for index, row in tqdm(df.iterrows(), total=len(df)):
            analysis = analyzer.analyze_text(row['text'])  # Assuming 'text' is your comment column
            results.append({
                'business_id': row['business_id'],
                'text': row['text'],
                'sentiment': analysis['sentiment'],
                'confidence': analysis['confidence']
            })

        # Convert results to DataFrame
        results_df = pd.DataFrame(results)
        # Save results
        output_path = 'sentiment_analysis_results.csv'
        results_df.to_csv(output_path, index=False)

        # Generate and save visualizations
        create_visualizations(results_df)

        # Print summary statistics
        print_summary(results_df)

        return results_df

    except Exception as e:
        print(f"Error processing file: {str(e)}")
        return None


def print_summary(df):
    """Print summary statistics of the analysis"""
    print("\nAnalysis Summary:")
    print("-" * 50)

    # Sentiment distribution
    print("\nSentiment Distribution:")
    sentiment_dist = df['sentiment'].value_counts()
    for sentiment, count in sentiment_dist.items():
        percentage = (count / len(df)) * 100
        print(f"{sentiment}: {count} ({percentage:.2f}%)")

    # Average confidence by sentiment
    print("\nAverage Confidence by Sentiment:")
    confidence_means = df.groupby('sentiment')['confidence'].mean()
    for sentiment, mean_conf in confidence_means.items():
        print(f"{sentiment}: {mean_conf:.4f}")

    # Business statistics
    print("\nBusiness Statistics:")
    business_sentiment = df.groupby('business_id')['sentiment'].value_counts()
    print(f"Total unique businesses: {df['business_id'].nunique()}")

    # Save summary to text file
    with open('analysis_summary.txt', 'w') as f:
        f.write(f"Analysis Date (UTC): {datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"User: Sudo-Rahman\n")
        f.write("-" * 50 + "\n\n")
        f.write("Sentiment Distribution:\n")
        for sentiment, count in sentiment_dist.items():
            percentage = (count / len(df)) * 100
            f.write(f"{sentiment}: {count} ({percentage:.2f}%)\n")
        f.write("\nAverage Confidence by Sentiment:\n")
        for sentiment, mean_conf in confidence_means.items():
            f.write(f"{sentiment}: {mean_conf:.4f}\n")
        f.write(f"\nTotal unique businesses: {df['business_id'].nunique()}\n")


if __name__ == "__main__":
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
    else:
        file_path = input("Enter the path to the CSV file: ")

    analyze_csv_file(file_path)