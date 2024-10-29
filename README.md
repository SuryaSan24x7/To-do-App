---

### **Episode Script: Building a To-Do List App (Using UIKit)**

---

#### **1. Introduction**

> **Script:** “Welcome back! In this episode, we’ll build a fully functional To-Do List app using UIKit. This app will allow users to add, edit, delete, and mark tasks as complete. We’ll utilize `UITableView` to display our tasks and manage the data with a custom `Task` struct, ensuring that data persists between app launches using `UserDefaults`.”

---

#### **2. Setting Up the Project and UI Elements**

1. **Create a New Xcode Project.**
   - Open Xcode > New Project > iOS App > Name it “ToDoListApp” > Use Storyboard as the interface.

2. **Set Up Main.storyboard with a Table View and Add Button.**
   - Drag a `UITableView` onto the view controller.
   - Add a bar button item at the top-right corner of the navigation bar and set its title to “Add.”
   - Create a custom `UITableViewCell` called `TaskTableViewCell` with a button for marking completion, a label for the task title, and a background view.

**Script:**
   > “We’ll begin by creating a simple UI with a table view to list our tasks and an 'Add' button to add new tasks. We’ll also create a custom cell to display our task details.”

---

#### **3. Creating the Data Model**

1. **Define the `Task` Model.**
   - Create a struct named `Task` that conforms to `Codable`. Each task will have a title and a completion status.

**Code:**
```swift
struct Task: Codable {
    var title: String
    var completed: Bool
}
```

**Script:**
   > “Our `Task` model is straightforward. Each task consists of a title and a Boolean indicating if it's completed.”

---

#### **4. Displaying Tasks in the Table View**

1. **Implement `UITableView` DataSource Methods.**
   - Use `numberOfRowsInSection` and `cellForRowAt` to display tasks in the table view.

**Code:**
```swift
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tasks.count
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell
    let task = tasks[indexPath.row]

    // Set the text and the completion status
    if task.completed {
        let attributeString = NSMutableAttributedString(string: task.title)
        attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        cell?.taskLabel.attributedText = attributeString
        cell?.taskLabel.textColor = .radioOn
        cell?.bgView.backgroundColor = .radioOnBg
    } else {
        cell?.taskLabel.attributedText = NSAttributedString(string: task.title)
        cell?.taskLabel.textColor = .radioOff
        cell?.bgView.backgroundColor = .radioOffBg
    }

    // Set the radio button image based on completion status
    let buttonImage = task.completed ? UIImage(named: "greenRadioButton") : UIImage(named: "redRadioButtonCross")
    cell?.taskButton.setImage(buttonImage, for: .normal)

    return cell ?? UITableViewCell()
}
```

**Script:**
   > “We’ll populate each cell in the table view using our `tasks` array. Completed tasks will be displayed with a strikethrough, while the corresponding radio button will indicate their status.”

---

#### **5. Adding New Tasks**

1. **Implement a Function to Add a Task.**
   - Use an alert with a text field to add new tasks.

**Code:**
```swift
@IBAction func addTask(_ sender: UIButton) {
    let alert = UIAlertController(title: "New Task", message: "Enter a task", preferredStyle: .alert)
    alert.addTextField()

    let addAction = UIAlertAction(title: "Add", style: .default) { _ in
        if let taskText = alert.textFields?.first?.text, !taskText.isEmpty {
            let newTask = Task(title: taskText, completed: false)
            self.tasks.append(newTask)
            self.saveTasks()
            self.tableView.reloadData()
        }
    }

    alert.addAction(addAction)
    present(alert, animated: true)
}
```

**Script:**
   > “The add function prompts users to enter a new task via an alert controller. When they press 'Add,' a new `Task` object is created and stored in our `tasks` array.”

---

#### **6. Saving and Loading Tasks with UserDefaults**

1. **Create Functions for Saving and Loading Data.**

**Code:**
```swift
func saveTasks() {
    if let encoded = try? JSONEncoder().encode(tasks) {
        UserDefaults.standard.set(encoded, forKey: "tasks")
    }
}

func loadTasks() {
    if let savedData = UserDefaults.standard.data(forKey: "tasks"),
       let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
        tasks = decodedTasks
    }
}
```

2. **Call `saveTasks()` when adding a new task and `loadTasks()` in `viewDidLoad`.**

**Script:**
   > “To persist our tasks, we use `UserDefaults`. Each time a task is added, we save the updated array, and when the app launches, we retrieve the saved data.”

---

#### **7. Marking Tasks as Complete and Deleting Tasks**

1. **Implement Completion Toggle in `didSelectRowAt`.**

**Code:**
```swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tasks[indexPath.row].completed.toggle()
    saveTasks()
    tableView.reloadRows(at: [indexPath], with: .automatic)
}
```

2. **Add Swipe Actions for Deleting and Editing Tasks.**

**Code:**
```swift
func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completionHandler in
        self.tasks.remove(at: indexPath.row)
        self.saveTasks()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        completionHandler(true)
    }
    
    deleteAction.backgroundColor = .white
    deleteAction.image = UIImage(named: "trashIcon")
    return UISwipeActionsConfiguration(actions: [deleteAction])
}

func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
    if !tasks[indexPath.row].completed {
        let editAction = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler in
            let alert = UIAlertController(title: "Edit Task", message: "Update your task", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = self.tasks[indexPath.row].title
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                    self.tasks[indexPath.row].title = newTitle
                    self.saveTasks()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                completionHandler(true)
            }
            
            alert.addAction(saveAction)
            self.present(alert, animated: true)
        }
        
        editAction.backgroundColor = .white
        editAction.image = UIImage(named: "editIcon")
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    return UISwipeActionsConfiguration()
}
```

**Script:**
   > “Users can swipe left to delete a task, which will remove it from the array and update the saved tasks. We also allow editing of tasks by swiping right, where an alert will prompt users to enter a new title.”

---

#### **8. Final Wrap-Up**

> **Script:** “And that’s it! We’ve built a fully functional To-Do List app using UIKit. Users can add, edit, delete, and mark tasks as complete, with all data saved between launches. You can enhance this app further by adding more features, such as due dates or notifications. Thank you for watching, and happy coding!”

---

### **Full Code (ViewController.swift)**

Here’s the completed code for your ViewController:

```swift
import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var tasks: [Task] = []
    
    struct Task: Codable {
        var title: String
        var completed: Bool
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        loadTasks()
    }
    
    @IBAction func addTask(_ sender: UIButton)

 {
        let alert = UIAlertController(title: "New Task", message: "Enter a task", preferredStyle: .alert)
        alert.addTextField()
        
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let taskText = alert.textFields?.first?.text, !taskText.isEmpty {
                let newTask = Task(title: taskText, completed: false)
                self.tasks.append(newTask)
                self.saveTasks()
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(addAction)
        present(alert, animated: true)
    }
    
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    func loadTasks() {
        if let savedData = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedData) {
            tasks = decodedTasks
        }
    }
    
    // MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskTableViewCell", for: indexPath) as? TaskTableViewCell
        cell?.selectionStyle = .none
        let task = tasks[indexPath.row]
        
        if task.completed {
            let attributeString = NSMutableAttributedString(string: task.title)
            attributeString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
            cell?.taskLabel.attributedText = attributeString
            cell?.taskLabel.textColor = .radioOn
            cell?.bgView.backgroundColor = .radioOnBg
        } else {
            cell?.taskLabel.attributedText = NSAttributedString(string: task.title)
            cell?.taskLabel.textColor = .radioOff
            cell?.bgView.backgroundColor = .radioOffBg
        }
        
        let buttonImage = task.completed ? UIImage(named: "greenRadioButton") : UIImage(named: "redRadioButtonCross")
        cell?.taskButton.setImage(buttonImage, for: .normal)
        
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasks[indexPath.row].completed.toggle()
        saveTasks()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, completionHandler in
            self.tasks.remove(at: indexPath.row)
            self.saveTasks()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .white
        deleteAction.image = UIImage(named: "trashIcon")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !tasks[indexPath.row].completed {
            let editAction = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler in
                let alert = UIAlertController(title: "Edit Task", message: "Update your task", preferredStyle: .alert)
                alert.addTextField { textField in
                    textField.text = self.tasks[indexPath.row].title
                }
                
                let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                    if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                        self.tasks[indexPath.row].title = newTitle
                        self.saveTasks()
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    completionHandler(true)
                }
                
                alert.addAction(saveAction)
                self.present(alert, animated: true)
            }
            
            editAction.backgroundColor = .white
            editAction.image = UIImage(named: "editIcon")
            return UISwipeActionsConfiguration(actions: [editAction])
        }
        return UISwipeActionsConfiguration()
    }
}
```

---
