import Foundation
import SwiftData

struct DefaultExerciseLibrary {

    static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Exercise>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        // Insert all exercises and build a name -> Exercise lookup
        var exercisesByName: [String: Exercise] = [:]
        for def in defaultExercises {
            let exercise = Exercise(name: def.name, bodyPart: def.bodyPart, exerciseType: def.exerciseType)
            modelContext.insert(exercise)
            exercisesByName[def.name] = exercise
        }

        // Create default templates
        for templateDef in defaultTemplates {
            let template = Template(name: templateDef.name)
            modelContext.insert(template)

            for (index, item) in templateDef.exercises.enumerated() {
                guard let exercise = exercisesByName[item.exerciseName] else { continue }
                let te = TemplateExercise(
                    exercise: exercise,
                    orderIndex: index,
                    plannedSetsCount: item.sets,
                    restSeconds: item.restSeconds
                )
                te.template = template
                modelContext.insert(te)
            }
        }

        try? modelContext.save()
    }

    // MARK: - Exercise definitions

    private struct ExerciseDef {
        let name: String
        let bodyPart: BodyPart
        let exerciseType: ExerciseType
    }

    // MARK: - Template definitions

    private struct TemplateDef {
        let name: String
        let exercises: [TemplateExerciseItem]
    }

    private struct TemplateExerciseItem {
        let exerciseName: String
        let sets: Int
        let restSeconds: Int
    }

    private static let defaultTemplates: [TemplateDef] = [
        TemplateDef(name: "Push", exercises: [
            TemplateExerciseItem(exerciseName: "Développé couché (barre)", sets: 4, restSeconds: 120),
            TemplateExerciseItem(exerciseName: "Développé incliné (haltères)", sets: 3, restSeconds: 90),
            TemplateExerciseItem(exerciseName: "Écarté à la poulie vis-à-vis", sets: 3, restSeconds: 60),
            TemplateExerciseItem(exerciseName: "Développé militaire (haltères)", sets: 3, restSeconds: 90),
            TemplateExerciseItem(exerciseName: "Élévations latérales (haltères)", sets: 3, restSeconds: 60),
            TemplateExerciseItem(exerciseName: "Extension triceps (corde)", sets: 3, restSeconds: 60),
        ]),
        TemplateDef(name: "Pull", exercises: [
            TemplateExerciseItem(exerciseName: "Tractions (pronation)", sets: 4, restSeconds: 120),
            TemplateExerciseItem(exerciseName: "Rowing barre", sets: 4, restSeconds: 90),
            TemplateExerciseItem(exerciseName: "Tirage vertical (poulie haute)", sets: 3, restSeconds: 90),
            TemplateExerciseItem(exerciseName: "Tirage horizontal (poulie basse)", sets: 3, restSeconds: 90),
            TemplateExerciseItem(exerciseName: "Face pull (poulie)", sets: 3, restSeconds: 60),
            TemplateExerciseItem(exerciseName: "Curl biceps (barre)", sets: 3, restSeconds: 60),
            TemplateExerciseItem(exerciseName: "Curl marteau (haltères)", sets: 3, restSeconds: 60),
        ]),
        TemplateDef(name: "Legs", exercises: [
            TemplateExerciseItem(exerciseName: "Squat (barre)", sets: 4, restSeconds: 150),
            TemplateExerciseItem(exerciseName: "Presse à cuisses", sets: 4, restSeconds: 120),
            TemplateExerciseItem(exerciseName: "Soulevé de terre roumain", sets: 3, restSeconds: 90),
            TemplateExerciseItem(exerciseName: "Leg extension (machine)", sets: 3, restSeconds: 60),
            TemplateExerciseItem(exerciseName: "Leg curl (machine)", sets: 3, restSeconds: 60),
            TemplateExerciseItem(exerciseName: "Mollets debout (machine)", sets: 4, restSeconds: 60),
        ]),
    ]

    private static let defaultExercises: [ExerciseDef] = [
        // MARK: - Pectoraux
        ExerciseDef(name: "Développé couché (barre)", bodyPart: .pectoraux, exerciseType: .barreLibre),
        ExerciseDef(name: "Développé couché (haltères)", bodyPart: .pectoraux, exerciseType: .poidsLibre),
        ExerciseDef(name: "Développé incliné (barre)", bodyPart: .pectoraux, exerciseType: .barreLibre),
        ExerciseDef(name: "Développé incliné (haltères)", bodyPart: .pectoraux, exerciseType: .poidsLibre),
        ExerciseDef(name: "Développé décliné (barre)", bodyPart: .pectoraux, exerciseType: .barreLibre),
        ExerciseDef(name: "Écarté couché (haltères)", bodyPart: .pectoraux, exerciseType: .poidsLibre),
        ExerciseDef(name: "Écarté à la poulie vis-à-vis", bodyPart: .pectoraux, exerciseType: .machine),
        ExerciseDef(name: "Pec deck (machine)", bodyPart: .pectoraux, exerciseType: .machine),
        ExerciseDef(name: "Pompes", bodyPart: .pectoraux, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Dips (pectoraux)", bodyPart: .pectoraux, exerciseType: .poidsDuCorps),

        // MARK: - Dos
        ExerciseDef(name: "Tractions (pronation)", bodyPart: .dos, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Tractions (supination)", bodyPart: .dos, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Rowing barre", bodyPart: .dos, exerciseType: .barreLibre),
        ExerciseDef(name: "Rowing haltère (un bras)", bodyPart: .dos, exerciseType: .poidsLibre),
        ExerciseDef(name: "Tirage vertical (poulie haute)", bodyPart: .dos, exerciseType: .machine),
        ExerciseDef(name: "Tirage horizontal (poulie basse)", bodyPart: .dos, exerciseType: .machine),
        ExerciseDef(name: "Soulevé de terre", bodyPart: .dos, exerciseType: .barreLibre),
        ExerciseDef(name: "Rowing T-bar", bodyPart: .dos, exerciseType: .barreLibre),
        ExerciseDef(name: "Tirage poitrine (machine)", bodyPart: .dos, exerciseType: .machine),
        ExerciseDef(name: "Pull-over (haltère)", bodyPart: .dos, exerciseType: .poidsLibre),

        // MARK: - Épaules
        ExerciseDef(name: "Développé militaire (barre)", bodyPart: .epaules, exerciseType: .barreLibre),
        ExerciseDef(name: "Développé militaire (haltères)", bodyPart: .epaules, exerciseType: .poidsLibre),
        ExerciseDef(name: "Élévations latérales (haltères)", bodyPart: .epaules, exerciseType: .poidsLibre),
        ExerciseDef(name: "Élévations frontales (haltères)", bodyPart: .epaules, exerciseType: .poidsLibre),
        ExerciseDef(name: "Oiseau (haltères)", bodyPart: .epaules, exerciseType: .poidsLibre),
        ExerciseDef(name: "Élévations latérales (poulie)", bodyPart: .epaules, exerciseType: .machine),
        ExerciseDef(name: "Face pull (poulie)", bodyPart: .epaules, exerciseType: .machine),
        ExerciseDef(name: "Développé Arnold", bodyPart: .epaules, exerciseType: .poidsLibre),
        ExerciseDef(name: "Shrugs (haltères)", bodyPart: .epaules, exerciseType: .poidsLibre),
        ExerciseDef(name: "Shrugs (barre)", bodyPart: .epaules, exerciseType: .barreLibre),

        // MARK: - Bras (Biceps)
        ExerciseDef(name: "Curl biceps (barre)", bodyPart: .bras, exerciseType: .barreLibre),
        ExerciseDef(name: "Curl biceps (haltères)", bodyPart: .bras, exerciseType: .poidsLibre),
        ExerciseDef(name: "Curl marteau (haltères)", bodyPart: .bras, exerciseType: .poidsLibre),
        ExerciseDef(name: "Curl incliné (haltères)", bodyPart: .bras, exerciseType: .poidsLibre),
        ExerciseDef(name: "Curl concentré", bodyPart: .bras, exerciseType: .poidsLibre),
        ExerciseDef(name: "Curl pupitre (barre EZ)", bodyPart: .bras, exerciseType: .barreLibre),
        ExerciseDef(name: "Curl à la poulie", bodyPart: .bras, exerciseType: .machine),

        // MARK: - Bras (Triceps)
        ExerciseDef(name: "Extension triceps (poulie haute)", bodyPart: .bras, exerciseType: .machine),
        ExerciseDef(name: "Extension triceps (corde)", bodyPart: .bras, exerciseType: .machine),
        ExerciseDef(name: "Barre au front (barre EZ)", bodyPart: .bras, exerciseType: .barreLibre),
        ExerciseDef(name: "Extension triceps (haltère, au-dessus de la tête)", bodyPart: .bras, exerciseType: .poidsLibre),
        ExerciseDef(name: "Dips (triceps)", bodyPart: .bras, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Kickback triceps (haltère)", bodyPart: .bras, exerciseType: .poidsLibre),

        // MARK: - Jambes
        ExerciseDef(name: "Squat (barre)", bodyPart: .jambes, exerciseType: .barreLibre),
        ExerciseDef(name: "Squat goblet (haltère)", bodyPart: .jambes, exerciseType: .poidsLibre),
        ExerciseDef(name: "Presse à cuisses", bodyPart: .jambes, exerciseType: .machine),
        ExerciseDef(name: "Fentes (haltères)", bodyPart: .jambes, exerciseType: .poidsLibre),
        ExerciseDef(name: "Fentes (barre)", bodyPart: .jambes, exerciseType: .barreLibre),
        ExerciseDef(name: "Leg extension (machine)", bodyPart: .jambes, exerciseType: .machine),
        ExerciseDef(name: "Leg curl (machine)", bodyPart: .jambes, exerciseType: .machine),
        ExerciseDef(name: "Soulevé de terre roumain", bodyPart: .jambes, exerciseType: .barreLibre),
        ExerciseDef(name: "Mollets debout (machine)", bodyPart: .jambes, exerciseType: .machine),
        ExerciseDef(name: "Mollets assis (machine)", bodyPart: .jambes, exerciseType: .machine),
        ExerciseDef(name: "Hack squat (machine)", bodyPart: .jambes, exerciseType: .machine),
        ExerciseDef(name: "Hip thrust (barre)", bodyPart: .jambes, exerciseType: .barreLibre),

        // MARK: - Fessiers
        ExerciseDef(name: "Hip thrust (haltère)", bodyPart: .fessiers, exerciseType: .poidsLibre),
        ExerciseDef(name: "Pont fessier (poids du corps)", bodyPart: .fessiers, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Kickback fessier (poulie)", bodyPart: .fessiers, exerciseType: .machine),
        ExerciseDef(name: "Abduction hanche (machine)", bodyPart: .fessiers, exerciseType: .machine),

        // MARK: - Abdos
        ExerciseDef(name: "Crunch", bodyPart: .abdos, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Crunch à la poulie", bodyPart: .abdos, exerciseType: .machine),
        ExerciseDef(name: "Relevé de jambes (suspendu)", bodyPart: .abdos, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Gainage (planche)", bodyPart: .abdos, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Russian twist", bodyPart: .abdos, exerciseType: .poidsDuCorps),
        ExerciseDef(name: "Ab wheel (roue abdominale)", bodyPart: .abdos, exerciseType: .poidsDuCorps),
    ]
}
