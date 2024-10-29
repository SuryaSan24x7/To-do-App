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

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Toggle completion status
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
        
        // Customize delete action button
        deleteAction.backgroundColor = .white // Set color for delete action
        deleteAction.image = UIImage(named: "trashIcon") // Optional icon
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Only add the edit action if the task is not completed
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
            
            // Customize edit action button
            editAction.backgroundColor = .white  // Set color for edit action
            editAction.image = UIImage(named: "editIcon")// Optional icon
            return UISwipeActionsConfiguration(actions: [editAction])
        }
        return UISwipeActionsConfiguration()
        
    }


}
