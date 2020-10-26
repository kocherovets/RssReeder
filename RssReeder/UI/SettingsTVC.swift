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
                UpdateIntervalCellVM(text: String(box.state.settings.updateIntervalSeconds),
                                     valueChangedCommand: CommandWith<Int> { value in
                                         trunk.dispatch(SettingsState.SetUpdateIntervalAction(seconds: value,
                                                                                              fromDB: false))
                                     }),
                SectionHeaderCellVM(title: "Sources"),
            ]

            rows.append(contentsOf:
                box.state.settings.sources.keys.sorted()
                .map { url in
                let isActive = box.state.settings.sources[url] == true
                return SourceCellVM(title: url,
                                    isActive: isActive,
                                    valueChangedCommand: Command {
                                        trunk.dispatch(SettingsState.SetSourceActivityAction(sourceURL: url,
                                                                                             activity: !isActive))
                                    },
                                    removeCommand: Command {
                                        trunk.dispatch(SettingsState.RemoveSourceAction(sourceURL: url))
                                    })
            })

            rows.append(
                AddSourceCellVM(
                    title: "Add source from clipoard",
                    selectCommand: Command {
                        if let url = UIPasteboard.general.string?.trimmingCharacters(in: .whitespaces) {
                            trunk.dispatch(SettingsState.AddSourcesAction(
                                sources: [SettingsState.AddSourcesAction.Info(url: url,
                                                                              active: true)],
                                fromDB: false))
                        }
                    }))
            if box.state.settings.sources.keys.first(where: { $0 == "http:////testdata.com" }) == nil {
                rows.append(
                    AddSourceCellVM(
                        title: "Add test 10000 news",
                        selectCommand: Command {
                            trunk.dispatch(ToDBInteractor.FillTestDataSE.StartAction())
                        })
                )
            }

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
