import 'package:flutter_test/flutter_test.dart';
import 'package:wality_application/wality_app/views_models/water_save_vm.dart';

void main() {
  group('Watersave - ', () {
    //Arrange
    final WaterSaveViewModel waterSave = WaterSaveViewModel();
    test(
        'Given watersave class when it is instantiated the value of mlSaved should be 0',
        () {
      //Act
      final val = waterSave.water.mlSaved;
      //Assert
      expect(val, 0);
    });
    test(
        'Given watersave class when it is add by 100 the value of mlSaved should be 100',
        () {
      //Act
      waterSave.addWater(100);
      final val = waterSave.water.mlSaved;
      //Assert
      expect(val, 100);
    });
    test(
        'Given watersave class when it is maxMl the value of savedCount should be 1',
        () {
      //Act
      waterSave.addWater(550);
      waterSave.checkAndIncrementSavedCount();
      final val = waterSave.water.savedCount;
      //Assert
      expect(val, 1);
    });
    test(
        'Given watersave class when savedCount be 1, mlSaved should comeback to be 0',
        () {
      //Act
      waterSave.addWater(550);
      waterSave.checkAndIncrementSavedCount();
      final val = waterSave.water.mlSaved;
      //Assert
      expect(val, 0);
    });
    test(
        'Given watersave class when it is maxMl 2 times the value of savedCount should be 2',
        () {
      //Act
      waterSave.checkAndIncrementSavedCount();
      final val = waterSave.water.savedCount;
      //Assert
      expect(val, 2);
    });
  });
}
