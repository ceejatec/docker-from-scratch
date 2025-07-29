# /// script
# dependencies = [
#   "requests<3"
# ]
# ///

import requests
import os
import sys
from urllib.parse import urlparse
from pathlib import Path

def download_file(url, filename=None, chunk_size=8192):
    """
    Download a file from a URL using requests.

    Args:
        url (str): The URL to download from
        filename (str, optional): Local filename to save as. If None, will use URL filename
        chunk_size (int): Size of chunks to download at a time (default: 8192 bytes)

    Returns:
        str: Path to the downloaded file, or None if failed
    """
    try:
        # Send GET request
        print(f"Connecting to {url}...")
        response = requests.get(url, stream=True)
        response.raise_for_status()  # Raise an exception for bad status codes

        # Determine filename if not provided
        if filename is None:
            # Try to get filename from URL
            parsed_url = urlparse(url)
            filename = os.path.basename(parsed_url.path)

            # If no filename in URL, use a default
            if not filename:
                filename = "downloaded_file"

            # Try to get filename from Content-Disposition header
            if 'content-disposition' in response.headers:
                content_disp = response.headers['content-disposition']
                if 'filename=' in content_disp:
                    filename = content_disp.split('filename=')[1].strip('"')

        # Get file size if available
        file_size = None
        if 'content-length' in response.headers:
            file_size = int(response.headers['content-length'])
            print(f"File size: {file_size:,} bytes ({file_size / 1024 / 1024:.2f} MB)")

        print(f"Downloading to: {filename}")

        # Download the file
        downloaded_bytes = 0
        with open(filename, 'wb') as file:
            for chunk in response.iter_content(chunk_size=chunk_size):
                if chunk:  # Filter out keep-alive chunks
                    file.write(chunk)
                    downloaded_bytes += len(chunk)

                    # Show progress if file size is known
                    if file_size:
                        progress = (downloaded_bytes / file_size) * 100
                        print(f"\rProgress: {progress:.1f}% ({downloaded_bytes:,}/{file_size:,} bytes)", end='', flush=True)
                    else:
                        print(f"\rDownloaded: {downloaded_bytes:,} bytes", end='', flush=True)

        print(f"\n✓ Download completed: {filename}")
        return filename

    except requests.exceptions.RequestException as e:
        print(f"✗ Error downloading file: {e}")
        return None
    except IOError as e:
        print(f"✗ Error saving file: {e}")
        return None
    except KeyboardInterrupt:
        print(f"\n✗ Download cancelled by user")
        # Clean up partial file
        if filename and os.path.exists(filename):
            os.remove(filename)
            print(f"Removed partial file: {filename}")
        return None

def main():
    """Main function to handle command line usage."""
    if len(sys.argv) < 2:
        print("Usage: python download_file.py <URL> [filename]")
        print("Example: python download_file.py https://example.com/file.zip")
        print("Example: python download_file.py https://example.com/file.zip my_file.zip")
        sys.exit(1)

    url = sys.argv[1]
    filename = sys.argv[2] if len(sys.argv) > 2 else None

    result = download_file(url, filename)
    if result:
        print(f"File saved as: {result}")
        sys.exit(0)
    else:
        sys.exit(1)

# Example usage
if __name__ == "__main__":
    # You can either run this script from command line or use the function directly
    main()

    # Alternative: Direct function usage example
    # download_file("https://httpbin.org/image/png", "test_image.png")