import time
from watchdog.observers import Observer
from watchdog.events import PatternMatchingEventHandler
import os
import sys

class MyHandler(PatternMatchingEventHandler):
  patterns = ["*.lua"]

  def on_modified(self, event):
    os.system("lua5.1 missions.lua")

if __name__ == "__main__":
  args = sys.argv[1:]
  observer = Observer()
  observer.schedule(MyHandler(), path=args[0] if args else '.')
  observer.start()

  try:
    while True:
      time.sleep(1)
  except KeyboardInterrupt:
    observer.stop()

  observer.join()
