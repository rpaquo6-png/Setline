import Foundation
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, Template.self, TemplateExercise.self,
        WorkoutSession.self, WorkoutSet.self,
        configurations: config
    )

    // Sample exercises
    let benchPress = Exercise(name: "Développé couché", bodyPart: .pectoraux, exerciseType: .barreLibre)
    let squat = Exercise(name: "Squat", bodyPart: .jambes, exerciseType: .barreLibre)
    let pullUp = Exercise(name: "Traction", bodyPart: .dos, exerciseType: .poidsDuCorps)
    let curl = Exercise(name: "Curl biceps", bodyPart: .bras, exerciseType: .poidsLibre)
    let ohp = Exercise(name: "Développé militaire", bodyPart: .epaules, exerciseType: .barreLibre)
    let legPress = Exercise(name: "Presse à cuisses", bodyPart: .jambes, exerciseType: .machine)
    let crunch = Exercise(name: "Crunch", bodyPart: .abdos, exerciseType: .poidsDuCorps)
    let hipThrust = Exercise(name: "Hip Thrust", bodyPart: .fessiers, exerciseType: .barreLibre)

    let exercises = [benchPress, squat, pullUp, curl, ohp, legPress, crunch, hipThrust]
    for exercise in exercises {
        container.mainContext.insert(exercise)
    }

    // Sample template: Push
    let pushTemplate = Template(name: "Push")
    container.mainContext.insert(pushTemplate)

    let te1 = TemplateExercise(exercise: benchPress, orderIndex: 0, plannedSetsCount: 4, restSeconds: 120)
    te1.template = pushTemplate
    container.mainContext.insert(te1)

    let te2 = TemplateExercise(exercise: ohp, orderIndex: 1, plannedSetsCount: 3, restSeconds: 90)
    te2.template = pushTemplate
    container.mainContext.insert(te2)

    pushTemplate.exercises = [te1, te2]

    // Sample template: Pull
    let pullTemplate = Template(name: "Pull")
    container.mainContext.insert(pullTemplate)

    let te3 = TemplateExercise(exercise: pullUp, orderIndex: 0, plannedSetsCount: 4, restSeconds: 90)
    te3.template = pullTemplate
    container.mainContext.insert(te3)

    let te4 = TemplateExercise(exercise: curl, orderIndex: 1, plannedSetsCount: 3, restSeconds: 60)
    te4.template = pullTemplate
    container.mainContext.insert(te4)

    pullTemplate.exercises = [te3, te4]

    // Sample template: Legs
    let legsTemplate = Template(name: "Legs")
    container.mainContext.insert(legsTemplate)

    let te5 = TemplateExercise(exercise: squat, orderIndex: 0, plannedSetsCount: 5, restSeconds: 180)
    te5.template = legsTemplate
    container.mainContext.insert(te5)

    let te6 = TemplateExercise(exercise: legPress, orderIndex: 1, plannedSetsCount: 4, restSeconds: 120)
    te6.template = legsTemplate
    container.mainContext.insert(te6)

    let te7 = TemplateExercise(exercise: hipThrust, orderIndex: 2, plannedSetsCount: 3, restSeconds: 90)
    te7.template = legsTemplate
    container.mainContext.insert(te7)

    legsTemplate.exercises = [te5, te6, te7]

    return container
}()
