//
//  ToolsTVC.swift
//  SwiftTrading
//
//  Created by Dmitry Kocherovets on 21.09.2020.
//  Copyright © 2020 Dmitry Kocherovets. All rights reserved.
//

import Foundation
import ReduxVM
import DITranquillity
import RedSwift
import DeclarativeTVC

enum SettingsTVCModule
{
    class Presenter: PresenterBase<AppState, TableProps, ViewController>
    {
        private var localDate = Date.distantPast

        override func reaction(for box: StateBox<AppState>) -> ReactionToState
        {
            return .props
        }

        override func props(for box: StateBox<AppState>, trunk: Trunk) -> TableProps?
        {
            var rows: [CellAnyModel] = [

                SectionHeaderCellVM(title: "General"),
                UpdateIntervalCellVM(text: String(box.state.updateIntervalSeconds),
                                     valueChangedCommand: CommandWith<Int> { value in
                                         trunk.dispatch(AppState.SetUpdateIntervalAction(seconds: value,
                                                                                      fromDB: false))
                                     }),
                SectionHeaderCellVM(title: "Sources"),
            ]

            rows.append(contentsOf:
                box.state.sources.keys.sorted()
                .map { url in
                    let isActive = box.state.sources[url] == true
                    return SourceCellVM(title: url,
                                        isActive: isActive,
                                        valueChangedCommand: Command {
                                            trunk.dispatch(AppState.SetSourceActivityAction(sourceURL: url, activity: !isActive))
                                        },
                                        removeCommand: Command {
                                            trunk.dispatch(AppState.RemoveSourceAction(sourceURL: url))
                                        })
            })

            rows.append(
                AddSourceCellVM(
                    selectCommand: Command {
                        if let url = UIPasteboard.general.string?.trimmingCharacters(in: .whitespaces) {
                            trunk.dispatch(AppState.AddSourcesAction(sources: [AppState.AddSourcesAction.Info(url: url,
                                                                                                        active: true)],
                                                                  fromDB: false))
                        }
                    }))

            return TableProps(tableModel: TableModel(rows: rows), animations: DeclarativeTVC.fadeAnimations)
        }
    }
}

class SettingsTVC: TVC, PropsReceiver
{
    typealias Props = TableProps

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if props?.tableModel.sections.first?.rows[indexPath.row] is SourceCellVM {
            return true
        }
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            if let vm = props?.tableModel.sections.first?.rows[indexPath.row] as? SourceCellVM {
                vm.removeCommand.perform()
            }
        }
    }
}

extension SettingsTVCModule
{
    typealias ViewController = SettingsTVC

    class DI: DIPart
    {
        static func load(container: DIContainer)
        {
            container.register(ViewController.self)
                .injection(\ViewController.presenter) {
                    $0 as Presenter
                }
                .lifetime(.objectGraph)

            container.register(Presenter.init)
                .injection(cycle: true, \Presenter.propsReceiver)
                .lifetime(.objectGraph)
        }
    }
}
