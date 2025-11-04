import requests
import threading
import time
import sys

def send_requests(url, duration=300):
    """Send continuous requests to the API"""
    end_time = time.time() + duration
    request_count = 0
    
    while time.time() < end_time:
        try:
            response = requests.get(url, timeout=5)
            request_count += 1
            if request_count % 100 == 0:
                print(f"Thread {threading.current_thread().name}: Sent {request_count} requests")
        except Exception as e:
            print(f"Error: {e}")
    
    print(f"Thread {threading.current_thread().name}: Completed {request_count} requests")

def generate_load(base_url, num_threads=10, duration=300):
    """Generate load using multiple threads"""
    print(f"Starting load test with {num_threads} threads for {duration} seconds...")
    print(f"Target URL: {base_url}")
    
    threads = []
    urls = [
        f"{base_url}/",
        f"{base_url}/sensor/temperature",
        f"{base_url}/sensor/humidity"
    ]
    
    for i in range(num_threads):
        url = urls[i % len(urls)]
        thread = threading.Thread(target=send_requests, args=(url, duration), name=f"Thread-{i+1}")
        threads.append(thread)
        thread.start()
    
    # Wait for all threads to complete
    for thread in threads:
        thread.join()
    
    print("Load test completed!")

if __name__ == "__main__":
    # Use localhost:30081 for NodePort service
    base_url = "http://localhost:30081"
    
    # Parse command line arguments
    num_threads = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    duration = int(sys.argv[2]) if len(sys.argv) > 2 else 300
    
    generate_load(base_url, num_threads, duration)
