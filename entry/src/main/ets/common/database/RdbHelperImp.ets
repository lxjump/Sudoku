/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { relationalStore } from '@kit.ArkData';
import tableHelper from './TableHelper';
import { RdbHelper } from './RdbHelper';
import ColumnInfo from '../../viewmodel/ColumnInfo';
import { LogUtil } from '../../utils/LogUtil';

export class RdbHelperImp implements RdbHelper {
  private mDatabaseName: string;
  private rdbStore: relationalStore.RdbStore = {} as relationalStore.RdbStore;
  private storeConfig: relationalStore.StoreConfig = {
    name: '',
    securityLevel: relationalStore.SecurityLevel.S1
  } as relationalStore.StoreConfig;

  constructor(databaseName: string) {
    this.mDatabaseName = databaseName;
  }

  getDbName(): string {
    return this.mDatabaseName;
  }

  getRdb(context: Context): Promise<RdbHelper> {
    this.storeConfig = {
      name: this.mDatabaseName, securityLevel: relationalStore.SecurityLevel.S1
    };
    return new Promise<RdbHelper>((success, error) => {
      relationalStore.getRdbStore(context, this.storeConfig).then(dbStore => {
        this.rdbStore = dbStore;
        success(this);
      }).catch((err: Error) => {
        LogUtil.error(`initRdb err : ${JSON.stringify(err)}`);
        error(err);
      })
    })
  }

  executeSql(sql: string): Promise<void> {
    LogUtil.info(`executeSql sql试一下 : ${sql}`);
    return this.rdbStore.executeSql(sql);
  }

  createTable(tableName: string, columns: Array<ColumnInfo>): Promise<void> {
    LogUtil.info(`createTable tableName : ${tableName}, columns : ${JSON.stringify(columns)}`);
    let createTableSql = tableHelper.createTableSql(tableName, columns);
    LogUtil.info(`createTable tableName3164 : ${createTableSql}`);
    return this.executeSql(createTableSql);
  }

  deleteTable(tableName: string): Promise<void> {
    LogUtil.info(`deleteTable tableName : ${tableName}`);
    let deleteTableSql = tableHelper.deleteTableSql(tableName);
    return this.executeSql(deleteTableSql);
  }

  addTableColumn(tableName: string, column: ColumnInfo): Promise<void> {
    LogUtil.info(`addTableColumn tableName : ${tableName}, column : ${JSON.stringify(column)}`);
    let addTableColumnSql = tableHelper.addTableColumnSql(tableName, column);
    return this.executeSql(addTableColumnSql);
  }

  insert(tableName: string, values: relationalStore.ValuesBucket | Array<relationalStore.ValuesBucket>): Promise<number> {
    return new Promise<number>((success, error) => {
      LogUtil.info(`insert tableName : ${tableName}, values : ${JSON.stringify(values)}`);
      if (!values) {
        LogUtil.info(`insert failed, values is undefined`);
        error(0);
        return;
      }
      if (values instanceof Array) {
        LogUtil.info(`insert values isArray = ${values.length}`);
        this.rdbStore.beginTransaction();
        this.saveArray(tableName, values).then(data => {
          LogUtil.info(`insert success, data : ${JSON.stringify(data)}`);
          success(data);
          this.rdbStore.commit();
        }).catch((err: Error) => {
          LogUtil.error(`insert failed, err : ${err}`);
          error(err);
          this.rdbStore.commit();
        })
      } else {
        this.rdbStore.insert(tableName, values).then(data => {
          LogUtil.info(`insert success id : ${data}`);
          success(data);
          this.rdbStore.commit();
        }).catch((err: Error) => {
          LogUtil.error(`insert failed, err : ${JSON.stringify(err)}`);
          error(err);
          this.rdbStore.commit();
        })
      }
    })
  }

  private saveArray(tableName: string, values: Array<relationalStore.ValuesBucket>): Promise<number> {
    return new Promise<number>((success, error) => {
      if (!values || values.length === 0) {
        error(0);
        return;
      }
      let index = 0
      let callback = (data: number, err: Error) => {
        if (err) {
          LogUtil.info(`saveArray failed, err : ${err}`);
          error(err);
          return;
        }
        if (data) {
          if (index < values.length - 1) {
            this.saveData(tableName, values, ++index, callback);
          } else {
            success(data);
          }
        }
      }
      this.saveData(tableName, values, index, callback);
    })
  }

  private saveData(tableName: string, values: Array<relationalStore.ValuesBucket>, index: number, callback: Function): void {
    LogUtil.info(`saveData tableName : ${tableName}, index : ${JSON.stringify(index)}`);
    this.rdbStore.insert(tableName, values[index]).then((data: number) => {
      LogUtil.info(`saveData success id : ${data}`);
      callback(data);
    }).catch((err: Error) => {
      LogUtil.error(`saveData failed, err : ${err}`);
      callback(err);
    })
  }

  update(values: relationalStore.ValuesBucket, rdbPredicates: relationalStore.RdbPredicates): Promise<number> {
    LogUtil.debug("RdbHelperImp update")
    return this.rdbStore.update(values, rdbPredicates);
  }

  query(rdbPredicates: relationalStore.RdbPredicates, columns?: Array<string>): Promise<relationalStore.ResultSet> {
    LogUtil.info(`query rdbPredicates : ${JSON.stringify(rdbPredicates)}`);
    return this.rdbStore.query(rdbPredicates, columns);
  }

  queryAll(tableName: string): Promise<relationalStore.ResultSet> {
    LogUtil.info(`queryAllSize tableName : ${tableName}`);
    return this.rdbStore.querySql(`select * from ${tableName}`);
  }

  queryBySql(sql: string, bindArgs?: Array<relationalStore.ValueType>): Promise<relationalStore.ResultSet> {
    LogUtil.info(`queryBySql sql : ${sql}`);
    return this.rdbStore.querySql(sql, bindArgs);
  }

  delete(rdbPredicates: relationalStore.RdbPredicates): Promise<number> {
    LogUtil.info(`delete rdbPredicates : ${JSON.stringify(rdbPredicates)}`);
    return this.rdbStore.delete(rdbPredicates);
  }
}
