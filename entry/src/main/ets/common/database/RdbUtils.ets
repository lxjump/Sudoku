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
import ColumnInfo from '../../viewmodel/ColumnInfo';
import { RdbHelper } from './RdbHelper';
import { RdbHelperImp } from './RdbHelperImp';
import { LogUtil } from '../../utils/LogUtil';

let dbContext: Context;
let mDatabaseName: string = '';

export class RdbUtils {
  private rdbHelpers = new Map<string, RdbHelper>();

  initDb(context: Context, databaseName: string) {
    dbContext = context;
    mDatabaseName = databaseName;
  }

  createDb(): Promise<RdbHelper> {
    return new Promise<RdbHelper>((success, error) => {
      let dbName = mDatabaseName;
      if (!dbContext || !dbName || dbName.length === 0) {
        error('init err');
        return;
      }
      let dbHelper = this.rdbHelpers.get(dbName);
      if (!dbHelper) {
        LogUtil.info(`initRdb  RdbUtils success`);
        let rdbHelper: RdbHelper = new RdbHelperImp(dbName);
        rdbHelper.getRdb(dbContext).then(data => {
          this.rdbHelpers.set(dbName, data);
          success(data);
        }).catch((err: Error) => {
          error(err);
        })
      } else {
        success(dbHelper);
      }
    })
  }

  deleteDb(context: Context, dbName: string): Promise<void> {
    this.rdbHelpers.delete(dbName);
    return relationalStore.deleteRdbStore(context, dbName);
  }

  createTable(tableName: string, columns: Array<ColumnInfo>): Promise<void> {
    return this.createDb().then(dbHelper => {
      return dbHelper.createTable(tableName, columns);
    });
  }

  isCreateTable(tableName: string, columns: Array<ColumnInfo>): Promise<boolean> {
    return this.createTable(tableName, columns).then(() => {
      return true;
    }).catch((error: Error) => {
      LogUtil.error('RdbUtils', 'create table error ' + JSON.stringify(error));
      return false;
    });
  }

  deleteTable(tableName: string): Promise<void> {
    return this.createDb().then(dbHelper => {
      return dbHelper.deleteTable(tableName);
    })
  }

  executeSql(sql: string): Promise<void> {
    return this.createDb().then(dbHelper => {
      return dbHelper.executeSql(sql);
    })
  }

  addTableColumn(tableName: string, column: ColumnInfo): Promise<void> {
    return this.createDb().then(dbHelper => {
      return dbHelper.addTableColumn(tableName, column);
    })
  }

  insert(tableName: string, values: relationalStore.ValuesBucket | Array<relationalStore.ValuesBucket>): Promise<number> {
    return this.createDb().then(dbHelper => {
      return dbHelper.insert(tableName, values);
    })
  }

  update(values: relationalStore.ValuesBucket, rdbPredicates: relationalStore.RdbPredicates): Promise<number> {
    return this.createDb().then(dbHelper => {
      LogUtil.debug("RdbUtils update")
      return dbHelper.update(values, rdbPredicates);
    })
  }

  query(rdbPredicates: relationalStore.RdbPredicates, columns?: Array<string>): Promise<relationalStore.ResultSet> {
    return this.createDb().then(dbHelper => {
      LogUtil.debug("RdbUtils query : " +  JSON.stringify(rdbPredicates))
      return dbHelper.query(rdbPredicates, columns);
    })
  }

  queryAll(tableName: string): Promise<relationalStore.ResultSet> {
    return this.createDb().then(dbHelper => {
      return dbHelper.queryAll(tableName);
    })
  }

  queryBySql(sql: string, bindArgs?: Array<relationalStore.ValueType>): Promise<relationalStore.ResultSet> {
    return this.createDb().then(dbHelper => {
      return dbHelper.queryBySql(sql, bindArgs);
    })
  }

  del(rdbPredicates: relationalStore.RdbPredicates): Promise<number> {
    return this.createDb().then(dbHelper => {
      return dbHelper.delete(rdbPredicates);
    })
  }
}

let rdbUtils = new RdbUtils();

export default rdbUtils as RdbUtils;