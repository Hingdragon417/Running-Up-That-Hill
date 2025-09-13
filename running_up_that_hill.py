#!/usr/bin/env python3
"""
Running Up That Hill - A Journey Simulator

Inspired by themes of empathy, understanding, and overcoming challenges together.
This program simulates the journey of two people trying to understand each other
by metaphorically "swapping places" and "running up that hill" together.
"""

import random
import time
import sys


class HillRunner:
    def __init__(self, name):
        self.name = name
        self.position = 0
        self.understanding = 0
        self.energy = 100
        
    def take_step(self):
        if self.energy > 0:
            step_size = random.randint(1, 3)
            self.position += step_size
            self.energy -= random.randint(5, 15)
            return step_size
        return 0
    
    def gain_understanding(self, amount):
        self.understanding += amount
        self.understanding = min(100, self.understanding)
    
    def rest(self):
        self.energy += random.randint(10, 20)
        self.energy = min(100, self.energy)


def simulate_journey():
    """Simulate two people's journey up the hill together."""
    print("=" * 50)
    print("🏔️  RUNNING UP THAT HILL - A Journey of Understanding  🏔️")
    print("=" * 50)
    print()
    
    runner1 = HillRunner("Person A")
    runner2 = HillRunner("Person B")
    
    hill_height = 100
    turn = 0
    
    print("Two people stand at the bottom of a great hill...")
    print("They wish to understand each other better by taking this journey together.")
    print(f"The hill is {hill_height} steps high. Let's see how they progress!\n")
    
    while runner1.position < hill_height and runner2.position < hill_height:
        turn += 1
        print(f"--- Turn {turn} ---")
        
        # Both runners take steps
        step1 = runner1.take_step()
        step2 = runner2.take_step()
        
        # They help each other understand
        if step1 > 0 and step2 > 0:
            understanding_gain = random.randint(2, 5)
            runner1.gain_understanding(understanding_gain)
            runner2.gain_understanding(understanding_gain)
            print(f"Both runners support each other, gaining understanding!")
        
        # Show progress
        print(f"{runner1.name}: Position {runner1.position}/{hill_height}, "
              f"Energy {runner1.energy}%, Understanding {runner1.understanding}%")
        print(f"{runner2.name}: Position {runner2.position}/{hill_height}, "
              f"Energy {runner2.energy}%, Understanding {runner2.understanding}%")
        
        # Rest if energy is low
        if runner1.energy < 20:
            runner1.rest()
            print(f"{runner1.name} takes a moment to rest and reflect.")
        if runner2.energy < 20:
            runner2.rest()
            print(f"{runner2.name} takes a moment to rest and reflect.")
        
        print()
        time.sleep(0.5)  # Small delay for dramatic effect
        
        # Break if both are too tired
        if runner1.energy <= 0 and runner2.energy <= 0:
            print("Both runners are exhausted and need to rest before continuing...")
            break
    
    # Show final results
    print("=" * 50)
    print("🎯 JOURNEY COMPLETE! 🎯")
    print("=" * 50)
    
    if runner1.position >= hill_height or runner2.position >= hill_height:
        print("They made it to the top of the hill!")
        print("Through their shared journey, they've gained new perspective.")
    else:
        print("Though they didn't reach the summit this time,")
        print("they've learned valuable lessons along the way.")
    
    avg_understanding = (runner1.understanding + runner2.understanding) / 2
    print(f"\nMutual Understanding Achieved: {avg_understanding:.1f}%")
    
    if avg_understanding >= 80:
        print("💫 Excellent! They now understand each other deeply.")
    elif avg_understanding >= 60:
        print("✨ Good progress! They have much better understanding.")
    elif avg_understanding >= 40:
        print("🌟 Some progress made in understanding each other.")
    else:
        print("🌱 The journey of understanding has just begun.")
    
    print("\nSometimes the most important thing isn't reaching the top,")
    print("but the understanding we gain along the way.")


def interactive_mode():
    """Allow user to make choices during the journey."""
    print("=" * 50)
    print("🏔️  INTERACTIVE HILL CLIMBING EXPERIENCE  🏔️")
    print("=" * 50)
    
    print("You are about to embark on a journey of understanding.")
    print("At each step, you can choose how to proceed.\n")
    
    your_position = 0
    partner_position = 0
    understanding = 0
    hill_height = 50
    
    while your_position < hill_height and partner_position < hill_height:
        print(f"Your position: {your_position}/{hill_height}")
        print(f"Partner's position: {partner_position}/{hill_height}")
        print(f"Mutual understanding: {understanding}%\n")
        
        print("What would you like to do?")
        print("1. Take a big step forward")
        print("2. Take a careful step and help your partner")
        print("3. Stop and listen to your partner")
        print("4. Rest and reflect")
        
        choice = input("\nEnter your choice (1-4): ").strip()
        
        if choice == "1":
            step = random.randint(3, 6)
            your_position += step
            print(f"You take a big step forward ({step} steps)!")
            
        elif choice == "2":
            step = random.randint(1, 3)
            your_position += step
            partner_position += random.randint(2, 4)
            understanding += random.randint(3, 6)
            print(f"You move carefully and help your partner along.")
            print("You both make progress together!")
            
        elif choice == "3":
            understanding += random.randint(5, 10)
            partner_position += random.randint(1, 2)
            print("You pause to truly listen and understand.")
            print("Your connection grows stronger!")
            
        elif choice == "4":
            understanding += random.randint(2, 4)
            print("You take time to rest and reflect on the journey.")
            
        else:
            print("Invalid choice. You pause, uncertain.")
        
        understanding = min(100, understanding)
        print()
    
    print("=" * 50)
    print("🎯 JOURNEY COMPLETE! 🎯")
    print(f"Final Understanding: {understanding}%")
    if understanding >= 70:
        print("You've achieved deep mutual understanding! 💫")
    else:
        print("You've made meaningful progress in understanding! ✨")


def main():
    print("Welcome to 'Running Up That Hill' - A Journey Simulator")
    print("\nThis program explores themes of empathy, understanding,")
    print("and the challenges we overcome when we try to see things")
    print("from another person's perspective.\n")
    
    while True:
        print("Choose your experience:")
        print("1. Watch a simulated journey")
        print("2. Take an interactive journey")
        print("3. Exit")
        
        choice = input("\nEnter your choice (1-3): ").strip()
        
        if choice == "1":
            simulate_journey()
        elif choice == "2":
            interactive_mode()
        elif choice == "3":
            print("\nThank you for exploring the journey of understanding!")
            print("Remember: 'If I only could, I'd make a deal with God...'")
            print("Sometimes the greatest gift is seeing through another's eyes. 💫")
            break
        else:
            print("Invalid choice. Please try again.")
        
        print("\n" + "="*50 + "\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nJourney interrupted. Take care! 🌟")
        sys.exit(0)