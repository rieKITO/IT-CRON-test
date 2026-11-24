import Foundation

/*:

Задание 1. Анализ кода

 В изначальном коде сначала выведется Алексей, а на втором сотруднике программа крашнется, потому что мы пытаемся вывести имя через force unwrap, а name второго сотрудника является nil
 
 Как можно исправить:
 
 1. Убрать force unwrap и обрабатывать nil случаи через ??. Например, можем сделать:
        print(employee.name ?? "Имя не указано")
    Тогда при name = nil у сотрудника будет выводиться "Имя не указано"
 
 2. Использовать if let, таким образом пропуская nil
    if let name = employee.name {
        print(name)
    }
    Тогда при name = nil тело if не отработает и ничего не крашнется
 
 3. Сделать name обязательным в структуре сотрудника

 Дополнительные улучшения:
 - isActive лучше сделать Bool, так как у поля всего 2 состояния
 - под gender можно сделать enum
 - массив лучше передавать в printEmployees параметром, чтобы функция не зависела от глобальной переменной
 - salary лучше сделать Decimal, если зарплата может быть с копейками
*/

struct Employee {
    let name: String?
    let age: Int
    let gender: String
    let salary: Int
    let isActive: String
}

let employees = [
    Employee(name: "Алексей", age: 25, gender: "Мужчина", salary: 150000, isActive: "Да"),
    Employee(name: nil, age: 30, gender: "Женщина", salary: 180000, isActive: "Да"),
    Employee(name: "Мария", age: 22, gender: "Женщина", salary: 90000, isActive: "Нет"),
    Employee(name: "Иван", age: 28, gender: "Мужчина", salary: 170000, isActive: "Да"),
    Employee(name: "Екатерина", age: 35, gender: "Женщина", salary: 210000, isActive: "Нет")
]

func printEmployees(_ employees: [Employee]) {
    for employee in employees {
        if let name = employee.name {
            print(name)
        }
    }
}

print("=== 1. Сотрудники ===")
printEmployees(employees)


// 2. Менеджер задач

enum TaskPriority: String {
    case low = "Низкий"
    case medium = "Средний"
    case high = "Высокий"
}

enum TaskStatus: String {
    case pending = "Не выполнена"
    case completed = "Завершена"
    case cancelled = "Отменена"
}

enum TaskManagerError: Error {
    case taskNotFound(UUID)
    case taskAlreadyExists(UUID)
}

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let createdAt: Date
    let priority: TaskPriority
    var status: TaskStatus

    init(
        title: String,
        description: String,
        createdAt: Date = Date(),
        priority: TaskPriority,
        status: TaskStatus
    ) {
        self.title = title
        self.description = description
        self.priority = priority
        self.createdAt = createdAt
        self.status = status
    }
}

final class TaskManager {
    
    private var tasks: [TaskItem] = []

    func addTask(_ task: TaskItem) throws {
        guard !tasks.contains(where: { $0.id == task.id }) else {
            throw TaskManagerError.taskAlreadyExists(task.id)
        }
        tasks.append(task)
    }

    func removeTask(id: UUID) throws {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw TaskManagerError.taskNotFound(id)
        }
        tasks.remove(at: index)
    }

    func updateStatus(id: UUID, to status: TaskStatus) throws {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else {
            throw TaskManagerError.taskNotFound(id)
        }
        tasks[index].status = status
    }

    func allTasks() -> [TaskItem] {
        return tasks
    }

    func completedTasks() -> [TaskItem] {
        return tasks.filter { $0.status == .completed }
    }

    func tasksWithPriority(_ priority: TaskPriority) -> [TaskItem] {
        return tasks.filter { $0.priority == priority }
    }

    func tasksSortedByCreationDate(ascending: Bool = true) -> [TaskItem] {
        return tasks.sorted {
            ascending ? $0.createdAt < $1.createdAt : $0.createdAt > $1.createdAt
        }
    }

}

// Проверка менеджера

func printTasks(_ tasks: [TaskItem]) {
    if tasks.isEmpty {
        print("\nСписок пуст")
        return
    }
    
    print("\nВсего задач: \(tasks.count)")
    
    for task in tasks {
        print("- \(task.title) | \(task.priority.rawValue) | \(task.status.rawValue)")
        print("  \(task.description)")
        print("  ID: \(task.id) | Создана: \(task.createdAt)")
    }
}

func demonstrateTaskManager() {
    let manager = TaskManager()
    
    let task1 = TaskItem(
        title: "Задача 1",
        description: "Описание задачи 1",
        createdAt: Date().addingTimeInterval(-3600),
        priority: .high,
        status: .pending
    )
    
    let task2 = TaskItem(
        title: "Задача 2",
        description: "Описание задачи 2",
        createdAt: Date(),
        priority: .medium,
        status: .pending
    )
    
    let task3 = TaskItem(
        title: "Задача 3",
        description: "Описание задачи 3",
        createdAt: Date().addingTimeInterval(-7200),
        priority: .low,
        status: .pending
    )
    
    let task4 = TaskItem(
        title: "Задача 4",
        description: "Описание задачи 4",
        createdAt: Date().addingTimeInterval(-3600),
        priority: .high,
        status: .pending
    )

    do {
        try manager.addTask(task1)
        try manager.addTask(task2)
        try manager.addTask(task3)
        try manager.addTask(task4)
    } catch TaskManagerError.taskAlreadyExists(let id) {
        print("Задача \(id) уже существует")
    } catch {
        print("Ошибка добавления: \(error)")
    }
    
    print("\n---- Все задачи: ----")
    printTasks(manager.allTasks())
    
    do {
        try manager.updateStatus(id: task1.id, to: .completed)
    } catch {
        print("\nНе удалось обновить статус")
    }
    
    print("\n---- Завершенные задачи: ----")
    printTasks(manager.completedTasks())
    
    print("\n---- Задачи с высоким приоритетом: ----")
    printTasks(manager.tasksWithPriority(.high))
    
    print("\n---- От старых к новым: ----")
    printTasks(manager.tasksSortedByCreationDate())
    
    print("\n---- От новных к старым: ----")
    printTasks(manager.tasksSortedByCreationDate(ascending: false))

    do {
        try manager.removeTask(id: task3.id)
    } catch TaskManagerError.taskNotFound(task3.id) {
        print("\nНе удалось найти задачу")
    } catch {
        print("Ошибка удаления: \(error)")
    }
    
    print("\n---- После удаления третьей задачи: ----")
    printTasks(manager.allTasks())
}

print("\n=== 2. Менеджер задач ===")
demonstrateTaskManager()
